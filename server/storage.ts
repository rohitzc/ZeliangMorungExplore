// Storage interface - currently not used as we're serving static data
// This file can be expanded if you need dynamic data management in the future

export interface IStorage {
  // Add storage methods as needed
}

export class MemStorage implements IStorage {
  constructor() {
    // Initialize storage if needed
  }
}

export const storage = new MemStorage();
