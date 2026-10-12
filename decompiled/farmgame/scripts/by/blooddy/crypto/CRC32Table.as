package by.blooddy.crypto
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import flash.utils.getQualifiedClassName;
   
   [ExcludeClass]
   public final class CRC32Table
   {
      
      private static var _table:ByteArray;
      
      public function CRC32Table()
      {
         super();
         Error.throwError(ArgumentError,2012,getQualifiedClassName(this));
      }
      
      public static function getTable() : ByteArray
      {
         if(!_table)
         {
            _table = createTable();
         }
         var result:ByteArray = new ByteArray();
         result.writeBytes(_table);
         return result;
      }
      
      private static function createTable() : ByteArray
      {
         var c:uint = 0;
         var j:uint = 0;
         var i:uint = 0;
         var result:ByteArray = new ByteArray();
         result.endian = Endian.LITTLE_ENDIAN;
         for(i = 0; i < 256; i++)
         {
            c = i;
            for(j = 0; j < 8; j++)
            {
               if(c & 1 == 1)
               {
                  c = uint(0xEDB88320 ^ c >>> 1);
               }
               else
               {
                  c >>>= 1;
               }
            }
            result.writeUnsignedInt(c);
         }
         return result;
      }
   }
}

