import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

export interface MediaItem {
  id: string;
  name: string;
  createTime: number;
  folderId: string;
}

export interface Photo extends MediaItem {}

export interface Folder {
  id: string;
  name: string;
  parentId: string;
  createTime: number;
}

@ObservedV2
export class MediaDataManager {
  @Trace folders: Folder[] = [];
  @Trace items: MediaItem[] = [];

  private preferencesStore: preferences.Preferences | null = null;
  private contentType: string = '';
  private preferencesName: string = '';

  constructor(contentType: string, preferencesName: string) {
    this.contentType = contentType;
    this.preferencesName = preferencesName;
  }

  async init(context: Context): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.preferencesName);
      await this.loadData();
    } catch (err) {
      console.error(`[MediaData:${this.contentType}] Failed to init:`, JSON.stringify(err));
    }
  }

  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substring(2, 9);
  }

  getRootFolders(): Folder[] {
    return this.folders.filter(folder => folder.parentId === '');
  }

  getSubFolders(parentId: string): Folder[] {
    return this.folders.filter(folder => folder.parentId === parentId);
  }

  getItemsInFolder(folderId: string): MediaItem[] {
    return this.items.filter(item => item.folderId === folderId);
  }

  addFolder(name: string, parentId: string): void {
    const newFolder: Folder = {
      id: this.generateId(),
      name: name,
      parentId: parentId,
      createTime: Date.now()
    };
    this.folders.push(newFolder);
    this.saveData();
  }

  addItem(name: string, folderId: string): void {
    const newItem: MediaItem = {
      id: this.generateId(),
      name: name,
      createTime: Date.now(),
      folderId: folderId
    };
    this.items.push(newItem);
    this.saveData();
  }

  deleteFolder(id: string): void {
    const foldersToDelete = new Set<string>();
    const collectSubFolders = (folderId: string): void => {
      foldersToDelete.add(folderId);
      const subFolders = this.getSubFolders(folderId);
      subFolders.forEach(sub => collectSubFolders(sub.id));
    };
    collectSubFolders(id);

    this.items = this.items.filter(item => !foldersToDelete.has(item.folderId));
    this.folders = this.folders.filter(folder => !foldersToDelete.has(folder.id));
    this.saveData();
  }

  renameFolder(id: string, newName: string): void {
    const folder = this.folders.find(f => f.id === id);
    if (folder) {
      folder.name = newName;
      this.saveData();
    }
  }

  async loadData(): Promise<void> {
    if (!this.preferencesStore) {
      console.warn(`[MediaData:${this.contentType}] Preferences not initialized`);
      return;
    }
    try {
      const foldersJson = await this.preferencesStore.get('folders', '[]') as string;
      const itemsJson = await this.preferencesStore.get('items', '[]') as string;
      this.folders = JSON.parse(foldersJson) as Folder[];
      this.items = JSON.parse(itemsJson) as MediaItem[];
    } catch (err) {
      console.error(`[MediaData:${this.contentType}] Failed to load:`, JSON.stringify(err));
      this.folders = [];
      this.items = [];
    }
  }

  async saveData(): Promise<void> {
    if (!this.preferencesStore) {
      console.warn(`[MediaData:${this.contentType}] Preferences not initialized`);
      return;
    }
    try {
      await this.preferencesStore.put('folders', JSON.stringify(this.folders));
      await this.preferencesStore.put('items', JSON.stringify(this.items));
      await this.preferencesStore.flush();
    } catch (err) {
      console.error(`[MediaData:${this.contentType}] Failed to save:`, JSON.stringify(err));
    }
  }

  // Backward compatibility aliases for PhotosPage / FolderDetailPage
  get photos(): MediaItem[] { return this.items; }
  getPhotosInFolder(folderId: string): MediaItem[] { return this.getItemsInFolder(folderId); }
  addPhoto(name: string, folderId: string): void { this.addItem(name, folderId); }
}

export const albumData = new MediaDataManager('photo', 'album_photo_data');
export const videoData = new MediaDataManager('video', 'album_video_data');
export const gifData = new MediaDataManager('gif', 'album_gif_data');
export const docData = new MediaDataManager('doc', 'album_doc_data');
export const recordData = new MediaDataManager('record', 'album_record_data');

export function getDataManager(type: string): MediaDataManager {
  switch (type) {
    case 'photo': return albumData;
    case 'video': return videoData;
    case 'gif': return gifData;
    case 'doc': return docData;
    case 'record': return recordData;
    default: return albumData;
  }
}
