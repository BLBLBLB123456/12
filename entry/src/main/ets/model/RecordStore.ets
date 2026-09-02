import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { CloudConfig, ObservationRecord } from './Types';

const STORE_NAME = 'behavior_observer';
const HISTORY_KEY = 'history';
const CLOUD_KEY = 'cloud_config';

export class RecordStore {
  static async list(context: common.UIAbilityContext): Promise<ObservationRecord[]> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw = await store.get(HISTORY_KEY, '[]') as string;
    try {
      return JSON.parse(raw) as ObservationRecord[];
    } catch (_) {
      return [];
    }
  }

  static async save(context: common.UIAbilityContext, record: ObservationRecord): Promise<void> {
    const items = await RecordStore.list(context);
    items.unshift(record);
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(HISTORY_KEY, JSON.stringify(items.slice(0, 50)));
    await store.flush();
  }

  static async get(context: common.UIAbilityContext, id: string): Promise<ObservationRecord | undefined> {
    return (await RecordStore.list(context)).find((item: ObservationRecord) => item.id === id);
  }

  static async feedback(context: common.UIAbilityContext, id: string, value: string): Promise<void> {
    const items = (await RecordStore.list(context)).map((item: ObservationRecord) => {
      if (item.id === id) {
        item.feedback = value;
      }
      return item;
    });
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(HISTORY_KEY, JSON.stringify(items));
    await store.flush();
  }

  static async clear(context: common.UIAbilityContext): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.delete(HISTORY_KEY);
    await store.flush();
  }

  static async cloudConfig(context: common.UIAbilityContext): Promise<CloudConfig> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    const raw = await store.get(CLOUD_KEY, '{"enabled":false,"endpoint":""}') as string;
    try {
      return JSON.parse(raw) as CloudConfig;
    } catch (_) {
      return { enabled: false, endpoint: '' };
    }
  }

  static async saveCloudConfig(context: common.UIAbilityContext, config: CloudConfig): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(CLOUD_KEY, JSON.stringify(config));
    await store.flush();
  }
}
