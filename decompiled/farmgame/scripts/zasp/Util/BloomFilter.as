package zasp.Util
{
   import flash.utils.ByteArray;
   
   public class BloomFilter
   {
      
      public static var RS:int = 0;
      
      public static var JS:int = 1;
      
      public static var PJW:int = 2;
      
      public static var ELF:int = 3;
      
      public static var BKDR:int = 4;
      
      public static var SDBM:int = 5;
      
      public static var DJB:int = 6;
      
      public static var DEK:int = 7;
      
      public static var BP:int = 8;
      
      public static var FNV:int = 9;
      
      public static var AP:int = 10;
      
      private var m_hashFns:Array;
      
      private var m_bloomFns:Array;
      
      private var m_results:ByteArray;
      
      private var m_len:int;
      
      public function BloomFilter(param1:Array, param2:int = 45)
      {
         var insertFns:Function;
         var i:int;
         var hashFns:Array = param1;
         var len:int = param2;
         super();
         this.m_hashFns = new Array(RSHash,JSHash,PJWHash,ELFHash,BKDRHash,SDBMHash,DJBHash,DEKHash,BPHash,FNVHash,APHash);
         this.m_bloomFns = new Array();
         insertFns = function(param1:*, param2:int, param3:Array):void
         {
            var _loc4_:int = int(param1);
            m_bloomFns.push(m_hashFns[_loc4_]);
         };
         hashFns.forEach(insertFns,this);
         this.m_results = new ByteArray();
         i = 0;
         while(i < len)
         {
            this.m_results.writeByte(0);
            i++;
         }
         this.m_len = len;
      }
      
      public static function RSHash(param1:String) : uint
      {
         var _loc2_:uint = 378551;
         var _loc3_:uint = 63689;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = _loc4_ * _loc3_ + uint(param1.charCodeAt(_loc5_));
            _loc3_ *= _loc2_;
            _loc5_++;
         }
         return _loc4_;
      }
      
      public static function JSHash(param1:String) : uint
      {
         var _loc2_:uint = 1315423911;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ ^= (_loc2_ << 5) + uint(param1.charCodeAt(_loc3_)) + (_loc2_ >> 2 & 0x3FFFFFFF);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function PJWHash(param1:String) : uint
      {
         var _loc2_:uint = uint(4 * 8);
         var _loc3_:uint = uint(_loc2_ * 3 / 4);
         var _loc4_:uint = uint(_loc2_ / 8);
         var _loc5_:uint = uint(uint(4294967295) << uint(_loc2_ - _loc4_));
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         var _loc11_:int = 0;
         while(_loc11_ < param1.length)
         {
            _loc6_ = uint(_loc6_ << _loc4_) + uint(param1.charCodeAt(_loc11_));
            _loc7_ = uint(_loc6_ & _loc5_);
            if(_loc7_ != 0)
            {
               _loc8_ = uint(_loc7_ >> _loc3_ & 0xFF);
               _loc9_ = uint(~_loc5_);
               _loc10_ = uint(_loc6_ ^ _loc8_);
               _loc6_ = uint(_loc10_ & _loc9_);
            }
            _loc11_++;
         }
         return _loc6_;
      }
      
      public static function ELFHash(param1:String) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = uint(_loc2_ << 4) + uint(param1.charCodeAt(_loc4_));
            _loc3_ = uint(_loc2_ & 0xF0000000);
            if(_loc3_ != 0)
            {
               _loc2_ ^= _loc3_ >> 24 & 0xFF;
            }
            _loc2_ &= ~_loc3_;
            _loc4_++;
         }
         return _loc2_;
      }
      
      public static function BKDRHash(param1:String) : uint
      {
         var _loc2_:uint = 131;
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = uint(_loc3_ * _loc2_) + uint(param1.charCodeAt(_loc4_));
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function SDBMHash(param1:String) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = uint(param1.charCodeAt(_loc3_)) + (_loc2_ << 6) + (_loc2_ << 16) - _loc2_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function DJBHash(param1:String) : uint
      {
         var _loc2_:uint = 5381;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = (_loc2_ << 5) + _loc2_ + uint(param1.charCodeAt(_loc3_));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function DEKHash(param1:String) : uint
      {
         var _loc2_:uint = uint(param1.length);
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = uint(_loc2_ << 5 ^ _loc2_ >> 27 & 0x1F ^ uint(param1.charCodeAt(_loc3_)));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function BPHash(param1:String) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = uint(_loc2_ << 7 ^ uint(param1.charCodeAt(_loc3_)));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function FNVHash(param1:String) : uint
      {
         var _loc2_:uint = 2166136261;
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ *= _loc2_;
            _loc3_ ^= uint(param1.charCodeAt(_loc4_));
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function APHash(param1:String) : uint
      {
         var _loc3_:uint = 0;
         var _loc2_:uint = 2863311530;
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = uint(param1.charCodeAt(_loc4_));
            if((_loc4_ & 1) == 0)
            {
               _loc2_ ^= _loc2_ << 7 ^ _loc3_ * (_loc2_ >> 3 & 0x1FFFFFFF);
            }
            else
            {
               _loc2_ ^= ~((_loc2_ << 11) + _loc3_ ^ _loc2_ >> 5 & 0x07FFFFFF);
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function BloomAdd(param1:String) : void
      {
         var str:String = param1;
         var setBit:Function = function(param1:*, param2:int, param3:Array):void
         {
            var _loc4_:int = int(m_results[param2]);
            var _loc5_:Function = param1;
            var _loc6_:int = _loc5_(str) % (m_len * 8);
            var _loc7_:int = _loc6_ / 8;
            var _loc8_:int = _loc6_ % 8;
            m_results[_loc7_] |= 1 << _loc8_;
         };
         this.m_bloomFns.forEach(setBit,this);
      }
      
      public function BloomClear() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_len)
         {
            this.m_results[_loc1_] = 0;
            _loc1_++;
         }
      }
      
      public function BloomCheck(param1:String) : Boolean
      {
         var str:String = param1;
         var getBit:Function = function(param1:*, param2:int, param3:Array):Boolean
         {
            var _loc4_:Function = param1;
            var _loc5_:int = _loc4_(str) % (m_len * 8);
            var _loc6_:int = int(m_results[int(_loc5_ / 8)]);
            if((_loc6_ & 1 << _loc5_ % 8) > 0)
            {
               return true;
            }
            return false;
         };
         return this.m_bloomFns.every(getBit,this);
      }
      
      public function checkString() : String
      {
         var _loc1_:String = "";
         _loc1_ = this.m_results[0].toString();
         var _loc2_:int = 1;
         while(_loc2_ < this.m_len)
         {
            _loc1_ += "," + this.m_results[_loc2_];
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function toString() : String
      {
         return Base64.encodeByteArray(this.m_results);
      }
   }
}

