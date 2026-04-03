# This is an example, really, you can use anything for the other side
# I am VERY fluent in Luau and... bad at python, so, vibecoded python side! sorry... );
import sys
import struct
import msgpack

class Bridge:
    def __init__(self, on_message_callback):
        """
        :param on_message_callback: A function that accepts (data, is_raw)
        """
        self.on_message_callback = on_message_callback

    def read_exact(self, n):
        data = b''
        while len(data) < n:
            packet = sys.stdin.buffer.read(n - len(data))
            if not packet: return None
            data += packet
        return data

    def send(self, data):
        # We'll stick to MsgPack for the return journey to keep it simple,
        # or you can implement the 5-byte header here too if Luau needs it.
        payload = msgpack.packb(data, use_bin_type=True)
        header = struct.pack('<I', len(payload))
        sys.stdout.buffer.write(header + payload)
        sys.stdout.buffer.flush()

    def listen(self):
        """The main loop that listens for Luau messages."""
        while True:
            # 1 byte (type) + 4 bytes (length) = 5 bytes
            header = self.read_exact(5)
            if not header: break
            
            # Unpack: 'B' for unsigned char (1 byte), 'I' for unsigned int (4 bytes)
            msg_type, payload_size = struct.unpack('<BI', header)
            
            payload = self.read_exact(payload_size)
            if payload is None: break

            try:
                if msg_type == 0:
                    # Raw Buffer: Pass payload directly
                    result = self.on_message_callback(payload, True)
                else:
                    # MessagePack: Decode first
                    decoded_data = msgpack.unpackb(payload, raw=False)
                    result = self.on_message_callback(decoded_data, False)
                
                if result is not None:
                    self.send(result)

            except Exception as e:
                sys.stderr.write(f"Bridge Error: {e}\n")
                sys.stderr.flush()
