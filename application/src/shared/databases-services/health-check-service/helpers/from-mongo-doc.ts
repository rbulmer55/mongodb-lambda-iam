import { ObjectId } from 'mongodb';

export function fromMongoDoc<T extends { _id: ObjectId }>(
  entity: T,
): Omit<T, '_id'> & { id: string } {
  const { _id, ...rest } = entity;
  return {
    ...rest,
    id: _id.toString(),
  };
}
