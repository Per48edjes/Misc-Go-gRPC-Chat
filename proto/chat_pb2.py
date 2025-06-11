"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import runtime_version as _runtime_version
from google.protobuf import symbol_database as _symbol_database
from google.protobuf.internal import builder as _builder
_runtime_version.ValidateProtobufRuntimeVersion(_runtime_version.Domain.PUBLIC, 5, 29, 0, '', 'chat.proto')
_sym_db = _symbol_database.Default()
DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\nchat.proto\x12\x04chat"?\n\x0bChatMessage\x12\x0c\n\x04user\x18\x01 \x01(\t\x12\x0f\n\x07message\x18\x02 \x01(\t\x12\x11\n\ttimestamp\x18\x03 \x01(\x032E\n\x0bChatService\x126\n\nChatStream\x12\x11.chat.ChatMessage\x1a\x11.chat.ChatMessage(\x010\x01B)Z\'github.com/Per48edjes/Misc-Go-gRPC-Chatb\x06proto3')
_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'chat_pb2', _globals)
if not _descriptor._USE_C_DESCRIPTORS:
    _globals['DESCRIPTOR']._loaded_options = None
    _globals['DESCRIPTOR']._serialized_options = b"Z'github.com/Per48edjes/Misc-Go-gRPC-Chat"
    _globals['_CHATMESSAGE']._serialized_start = 20
    _globals['_CHATMESSAGE']._serialized_end = 83
    _globals['_CHATSERVICE']._serialized_start = 85
    _globals['_CHATSERVICE']._serialized_end = 154