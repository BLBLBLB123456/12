import { http } from '@kit.NetworkKit';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { CloudConfig, CloudResponse, ObservableTag, Observation, ObservationRecord } from './Types';

export const OBSERVABLE_TAGS: ObservableTag[] = [
  { key: 'open', label: '姿态舒展', note: '画面中身体姿态看起来较开放。' },
  { key: 'closed', label: '姿态收拢', note: '画面中身体姿态看起来较收拢。' },
  { key: 'eye', label: '视线集中', note: '视线方向在当前画面中相对稳定。' },
  { key: 'away', label: '视线偏移', note: '视线似乎偏向画面之外。' },
  { key: 'active', label: '动作明显', note: '可见动作幅度相对明显。' },
  { key: 'still', label: '相对静止', note: '当前画面呈现较静止的状态。' }
];

export function localAnalyze(imageUri: string, keys: string[]): ObservationRecord {
  let observations: Observation[] = OBSERVABLE_TAGS
    .filter((tag: ObservableTag) => keys.includes(tag.key))
    .map((tag: ObservableTag): Observation => {
      const observation: Observation = { label: tag.label, note: tag.note };
      return observation;
    });
  if (observations.length === 0) {
    observations = [{
      label: '画面已记录',
      note: '单张图片不足以稳定判断动作变化，建议结合连续观察。'
    }];
  }
  return {
    id: Date.now().toString(),
    createdAt: Date.now(),
    imageUri,
    mode: '本地观察',
    observations,
    summary: observations.map((item: Observation) => item.label).join('、'),
    suggestion: '请把这些描述当作沟通线索，通过提问和情境信息验证，不应据此判断性格、意图或心理健康状态。',
    feedback: ''
  };
}

async function imageAsBase64(imageUri: string): Promise<string> {
  const file = fileIo.openSync(imageUri, fileIo.OpenMode.READ_ONLY);
  try {
    const stat = fileIo.statSync(file.fd);
    if (stat.size > 8 * 1024 * 1024) {
      throw new Error('图片不能超过 8MB');
    }
    const buffer = new ArrayBuffer(stat.size);
    fileIo.readSync(file.fd, buffer);
    const helper = new util.Base64Helper();
    return helper.encodeToStringSync(new Uint8Array(buffer), util.Type.BASIC);
  } finally {
    fileIo.closeSync(file);
  }
}

async function cloudAnalyze(imageUri: string, keys: string[], endpoint: string): Promise<CloudResponse> {
  const client = http.createHttp();
  try {
    const imageBase64 = await imageAsBase64(imageUri);
    const response = await client.request(endpoint, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      connectTimeout: 15000,
      readTimeout: 30000,
      extraData: JSON.stringify({ imageBase64, tags: keys })
    });
    if (response.responseCode < 200 || response.responseCode >= 300) {
      throw new Error(`云端返回状态码 ${response.responseCode}`);
    }
    const parsed = JSON.parse(response.result.toString()) as CloudResponse;
    if (!parsed.observations || !Array.isArray(parsed.observations)) {
      throw new Error('云端响应格式不正确');
    }
    return parsed;
  } finally {
    client.destroy();
  }
}

export async function analyze(imageUri: string, keys: string[], config: CloudConfig): Promise<ObservationRecord> {
  const local = localAnalyze(imageUri, keys);
  if (!config.enabled || !config.endpoint) {
    return local;
  }
  try {
    const remote = await cloudAnalyze(imageUri, keys, config.endpoint);
    return {
      id: local.id,
      createdAt: local.createdAt,
      imageUri: local.imageUri,
      mode: '云端辅助',
      observations: remote.observations,
      summary: remote.summary,
      suggestion: remote.suggestion,
      feedback: local.feedback
    };
  } catch (error) {
    return {
      id: local.id,
      createdAt: local.createdAt,
      imageUri: local.imageUri,
      mode: '本地观察（云端不可用）',
      observations: local.observations,
      summary: local.summary,
      suggestion: local.suggestion,
      feedback: local.feedback
    };
  }
}
