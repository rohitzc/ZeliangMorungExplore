// Storage interface - currently not used as we're serving static data
// This file can be expanded if you need dynamic data management in the future

export interface IStorage {
  getVisitorCount(): number;
  incrementVisitorCount(): number;
}

export class MemStorage implements IStorage {
  private visitorCount: number = 0;

  constructor() {
    // Initialize storage if needed
  }

  getVisitorCount(): number {
    return this.visitorCount;
  }

  incrementVisitorCount(): number {
    this.visitorCount += 1;
    return this.visitorCount;
  }
}

export const storage = new MemStorage();
