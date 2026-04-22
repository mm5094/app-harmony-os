import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

/**
 * Photo interface - represents a single photo in the album
 */
export interface Photo {
  id: string;
  name: string;
  createTime: number;
  folderId: string;
}

/**
 * Folder interface - represents a folder/directory in the album
 */
export interface Folder {
  id: string;
  name: string;
  parentId: string;
  createTime: number;
}

/**
 * AlbumDataManager - manages folders and photos with persistence
 */
@ObservedV2
export class AlbumDataManager {
  @Trace folders: Folder[] = [];
  @Trace photos: Photo[] = [];

  private preferencesStore: preferences.Preferences | null = null;
  private readonly PREFERENCES_NAME = 'album_data';
  private readonly KEY_FOLDERS = 'folders';
  private readonly KEY_PHOTOS = 'photos';

  /**
   * Initialize preferences store
   */
  async init(context: Context): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.PREFERENCES_NAME);
      await this.loadData();
    } catch (err) {
      console.error('[AlbumData] Failed to init preferences:', JSON.stringify(err));
    }
  }

  /**
   * Generate unique ID
   */
  private generateId(): string {
    return Date.now().toString() + Math.random().toString(36).substring(2, 9);
  }

  /**
   * Get root folders (parentId === '')
   */
  getRootFolders(): Folder[] {
    return this.folders.filter(folder => folder.parentId === '');
  }

  /**
   * Get sub-folders of a parent folder
   */
  getSubFolders(parentId: string): Folder[] {
    return this.folders.filter(folder => folder.parentId === parentId);
  }

  /**
   * Get photos in a specific folder
   */
  getPhotosInFolder(folderId: string): Photo[] {
    return this.photos.filter(photo => photo.folderId === folderId);
  }

  /**
   * Add a new folder
   */
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

  /**
   * Add a new photo (placeholder for actual import)
   */
  addPhoto(name: string, folderId: string): void {
    const newPhoto: Photo = {
      id: this.generateId(),
      name: name,
      createTime: Date.now(),
      folderId: folderId
    };
    this.photos.push(newPhoto);
    this.saveData();
  }

  /**
   * Delete a folder and all its sub-folders and photos recursively
   */
  deleteFolder(id: string): void {
    // Collect all folder IDs to delete (including sub-folders)
    const foldersToDelete = new Set<string>();
    const collectSubFolders = (folderId: string): void => {
      foldersToDelete.add(folderId);
      const subFolders = this.getSubFolders(folderId);
      subFolders.forEach(sub => collectSubFolders(sub.id));
    };
    collectSubFolders(id);

    // Delete all photos in these folders
    this.photos = this.photos.filter(photo => !foldersToDelete.has(photo.folderId));

    // Delete all folders
    this.folders = this.folders.filter(folder => !foldersToDelete.has(folder.id));

    this.saveData();
  }

  /**
   * Rename a folder
   */
  renameFolder(id: string, newName: string): void {
    const folder = this.folders.find(f => f.id === id);
    if (folder) {
      folder.name = newName;
      this.saveData();
    }
  }

  /**
   * Load data from preferences
   */
  async loadData(): Promise<void> {
    if (!this.preferencesStore) {
      console.warn('[AlbumData] Preferences store not initialized');
      return;
    }

    try {
      const foldersJson = await this.preferencesStore.get(this.KEY_FOLDERS, '[]') as string;
      const photosJson = await this.preferencesStore.get(this.KEY_PHOTOS, '[]') as string;

      this.folders = JSON.parse(foldersJson) as Folder[];
      this.photos = JSON.parse(photosJson) as Photo[];

      console.info('[AlbumData] Data loaded successfully');
    } catch (err) {
      console.error('[AlbumData] Failed to load data:', JSON.stringify(err));
      this.folders = [];
      this.photos = [];
    }
  }

  /**
   * Save data to preferences
   */
  async saveData(): Promise<void> {
    if (!this.preferencesStore) {
      console.warn('[AlbumData] Preferences store not initialized');
      return;
    }

    try {
      await this.preferencesStore.put(this.KEY_FOLDERS, JSON.stringify(this.folders));
      await this.preferencesStore.put(this.KEY_PHOTOS, JSON.stringify(this.photos));
      await this.preferencesStore.flush();

      console.info('[AlbumData] Data saved successfully');
    } catch (err) {
      console.error('[AlbumData] Failed to save data:', JSON.stringify(err));
    }
  }
}

/**
 * Global album data manager instance
 */
export const albumData = new AlbumDataManager();
