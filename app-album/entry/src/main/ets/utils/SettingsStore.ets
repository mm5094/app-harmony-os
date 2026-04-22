import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

const PREFS_NAME = 'album_settings';

const KEY_AUTO_LOCK = 'auto_lock';
const KEY_LOCK_DELAY = 'lock_delay';
const KEY_AUTO_BACKUP = 'auto_backup';
const KEY_LANGUAGE = 'language';
const KEY_FACE_ID = 'face_id_enabled';
const KEY_FOLDER_ACCESS = 'folder_face_id_access';
const KEY_INTRUDER = 'intruder_photo_enabled';

export class SettingsStore {
  private prefs: dataPreferences.Preferences | null = null;

  async init(context: common.UIAbilityContext): Promise<void> {
    this.prefs = await dataPreferences.getPreferences(context, PREFS_NAME);
  }

  private ensureInit(): void {
    if (!this.prefs) {
      throw new Error('SettingsStore not initialized');
    }
  }

  async getAutoLock(): Promise<boolean> {
    this.ensureInit();
    return await this.prefs!.get(KEY_AUTO_LOCK, true) as boolean;
  }

  async setAutoLock(value: boolean): Promise<void> {
    this.ensureInit();
    await this.prefs!.put(KEY_AUTO_LOCK, value);
    await this.prefs!.flush();
  }

  async getLockDelay(): Promise<number> {
    this.ensureInit();
    return await this.prefs!.get(KEY_LOCK_DELAY, 1) as number;
  }

  async setLockDelay(value: number): Promise<void> {
    this.ensureInit();
    await this.prefs!.put(KEY_LOCK_DELAY, value);
    await this.prefs!.flush();
  }

  async getAutoBackup(): Promise<boolean> {
    this.ensureInit();
    return await this.prefs!.get(KEY_AUTO_BACKUP, false) as boolean;
  }

  async setAutoBackup(value: boolean): Promise<void> {
    this.ensureInit();
    await this.prefs!.put(KEY_AUTO_BACKUP, value);
    await this.prefs!.flush();
  }

  async getLanguage(): Promise<string> {
    this.ensureInit();
    return await this.prefs!.get(KEY_LANGUAGE, 'zh-CN') as string;
  }

  async setLanguage(value: string): Promise<void> {
    this.ensureInit();
    await this.prefs!.put(KEY_LANGUAGE, value);
    await this.prefs!.flush();
  }

  async getFaceIdEnabled(): Promise<boolean> {
    this.ensureInit();
    return await this.prefs!.get(KEY_FACE_ID, false) as boolean;
  }

  async setFaceIdEnabled(value: boolean): Promise<void> {
    this.ensureInit();
    await this.prefs!.put(KEY_FACE_ID, value);
    await this.prefs!.flush();
  }

  async getFolderFaceIdAccess(): Promise<boolean> {
    this.ensureInit();
    return await this.prefs!.get(KEY_FOLDER_ACCESS, false) as boolean;
  }

  async setFolderFaceIdAccess(value: boolean): Promise<void> {
    this.ensureInit();
    await this.prefs!.put(KEY_FOLDER_ACCESS, value);
    await this.prefs!.flush();
  }

  async getIntruderPhotoEnabled(): Promise<boolean> {
    this.ensureInit();
    return await this.prefs!.get(KEY_INTRUDER, false) as boolean;
  }

  async setIntruderPhotoEnabled(value: boolean): Promise<void> {
    this.ensureInit();
    await this.prefs!.put(KEY_INTRUDER, value);
    await this.prefs!.flush();
  }
}

export const settingsStore = new SettingsStore();
