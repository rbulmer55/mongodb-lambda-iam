import { ObjectId } from 'mongodb';

export function toMongoDoc<T extends { id: string }>(entity: T) {
  const { id, ...rest } = entity;
  return {
    _id: !id ? new ObjectId() : new ObjectId(id),
    ...rest,
  };
}
