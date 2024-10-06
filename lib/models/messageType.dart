

enum MessageType{
  TEXT,
  VOICE_RECORD,
  IMAGE,
  IMAGE_AND_TEXT,
  ITEM;

  const MessageType();
}

MessageType numToMessageType(int num){
  return MessageType.values[num];
}