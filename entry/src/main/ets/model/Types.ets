export interface ObservableTag {
  key: string;
  label: string;
  note: string;
  selected?: boolean;
}

export interface Observation {
  label: string;
  note: string;
}

export interface ObservationRecord {
  id: string;
  createdAt: number;
  imageUri: string;
  mode: string;
  observations: Observation[];
  summary: string;
  suggestion: string;
  feedback: string;
}

export interface CloudConfig {
  enabled: boolean;
  endpoint: string;
}

export interface CloudResponse {
  observations: Observation[];
  summary: string;
  suggestion: string;
}

