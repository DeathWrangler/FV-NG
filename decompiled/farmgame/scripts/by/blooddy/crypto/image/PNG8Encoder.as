package by.blooddy.crypto.image
{
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import by.blooddy.crypto.CRC32;
   import by.blooddy.crypto.image.palette.IPalette;
   import by.blooddy.crypto.image.palette.MedianCutPalette;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.ByteArray;
   
   public class PNG8Encoder
   {
      
      public function PNG8Encoder()
      {
      }
      
      public static function encode(param1:BitmapData, param2:IPalette = undefined, param3:int = 0) : ByteArray
      {
         var _loc14_:* = null as Vector.<uint>;
         var _loc15_:uint = 0;
         var _loc16_:uint = 0;
         var _loc17_:* = 0;
         var _loc18_:* = 0;
         var _loc19_:uint = 0;
         var _loc20_:uint = 0;
         var _loc21_:uint = 0;
         var _loc22_:uint = 0;
         var _loc23_:uint = 0;
         var _loc24_:uint = 0;
         var _loc25_:uint = 0;
         var _loc26_:* = 0;
         var _loc27_:* = 0;
         var _loc28_:uint = 0;
         var _loc29_:uint = 0;
         if(param1 == null)
         {
            Error.throwError(TypeError,2007,"image");
         }
         if(param3 < 0 || param3 > 4)
         {
            Error.throwError(ArgumentError,2008,"filter");
         }
         if(param2 == null)
         {
            param2 = new MedianCutPalette(param1);
         }
         var _loc4_:ByteArray = ApplicationDomain.currentDomain.domainMemory;
         var _loc5_:Boolean = param1.transparent && (param1.getPixel32(0,0) < 4278190080 || (param1.getPixel32(param1.width,param1.height) < 4278190080 || (param1.getPixel32(param1.width,0) < 4278190080 || (param1.getPixel32(0,param1.height) < 4278190080 || param1.clone().threshold(param1,param1.rect,new Point(),"!=",4278190080,0,4278190080,true) != 0))));
         var _loc6_:uint = uint(param1.width);
         var _loc7_:uint = uint(param1.height);
         var _loc8_:uint = _loc6_ * _loc7_ + _loc7_;
         var _loc9_:uint = _loc8_ + _loc6_;
         var _loc11_:ByteArray = new ByteArray();
         var _loc13_:ByteArray = new ByteArray();
         if(_loc9_ != 0)
         {
            _loc13_.length = _loc9_;
         }
         var _loc12_:ByteArray = _loc13_;
         _loc11_.writeUnsignedInt(-1991225785);
         _loc11_.writeUnsignedInt(218765834);
         _loc12_.length = 0;
         _loc12_.writeUnsignedInt(1229472850);
         _loc12_.writeUnsignedInt(_loc6_);
         _loc12_.writeUnsignedInt(_loc7_);
         _loc12_.writeByte(8);
         _loc12_.writeByte(3);
         _loc12_.writeByte(0);
         _loc12_.writeByte(0);
         _loc12_.writeByte(0);
         _loc11_.writeUnsignedInt(_loc12_.length - 4);
         _loc11_.writeBytes(_loc12_,0);
         _loc11_.writeUnsignedInt(CRC32.hash(_loc12_));
         if(_loc5_)
         {
            if(1028 < ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH)
            {
               _loc12_.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
            }
            else
            {
               _loc12_.length = 1028;
            }
            ApplicationDomain.currentDomain.domainMemory = _loc12_;
            _loc14_ = param2.getColors();
            _loc16_ = uint(int(_loc14_.length));
            _loc15_ = _loc16_ < 256 ? _loc16_ : 256;
            _loc16_ = 4;
            _loc17_ = 772;
            _loc18_ = 0;
            do
            {
               _loc19_ = _loc14_[_loc18_];
               var _temp_6:* = _loc19_ >> 24;
               _loc17_ = uint((_loc20_ = _loc17_) + 1);
               si8(_temp_6,_loc20_);
               var _temp_8:* = _loc19_ >> 16;
               _loc16_ = (_loc20_ = _loc16_) + 1;
               si8(_temp_8,_loc20_);
               var _temp_10:* = _loc19_ >> 8;
               _loc16_ = (_loc20_ = _loc16_) + 1;
               si8(_temp_10,_loc20_);
               var _temp_12:* = _loc19_;
               _loc16_ = (_loc20_ = _loc16_) + 1;
               si8(_temp_12,_loc20_);
            }
            while(++_loc18_ < _loc15_);
            ApplicationDomain.currentDomain.domainMemory = null;
            _loc12_.position = 0;
            _loc12_.writeUnsignedInt(1347179589);
            _loc12_.length = 4 + 3 * _loc15_;
            _loc11_.writeUnsignedInt(_loc12_.length - 4);
            _loc11_.writeBytes(_loc12_,0);
            _loc11_.writeUnsignedInt(CRC32.hash(_loc12_));
            _loc12_.length = 1028;
            _loc12_.position = 0;
            _loc12_.writeUnsignedInt(1951551059);
            _loc12_.writeBytes(_loc12_,772,_loc15_);
            _loc12_.length = _loc15_ + 4;
            _loc11_.writeUnsignedInt(_loc12_.length - 4);
            _loc11_.writeBytes(_loc12_,0);
            _loc11_.writeUnsignedInt(CRC32.hash(_loc12_));
         }
         else
         {
            if(1028 < ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH)
            {
               _loc12_.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
            }
            else
            {
               _loc12_.length = 1028;
            }
            ApplicationDomain.currentDomain.domainMemory = _loc12_;
            _loc14_ = param2.getColors();
            _loc16_ = uint(int(_loc14_.length));
            _loc15_ = _loc16_ < 256 ? _loc16_ : 256;
            _loc16_ = 4;
            _loc17_ = 772;
            _loc18_ = 0;
            do
            {
               _loc19_ = _loc14_[_loc18_];
               var _temp_18:* = _loc19_ >> 16;
               _loc16_ = (_loc20_ = _loc16_) + 1;
               si8(_temp_18,_loc20_);
               var _temp_20:* = _loc19_ >> 8;
               _loc16_ = (_loc20_ = _loc16_) + 1;
               si8(_temp_20,_loc20_);
               var _temp_22:* = _loc19_;
               _loc16_ = (_loc20_ = _loc16_) + 1;
               si8(_temp_22,_loc20_);
            }
            while(++_loc18_ < _loc15_);
            ApplicationDomain.currentDomain.domainMemory = null;
            _loc12_.position = 0;
            _loc12_.writeUnsignedInt(1347179589);
            _loc12_.length = 4 + 3 * _loc15_;
            _loc11_.writeUnsignedInt(_loc12_.length - 4);
            _loc11_.writeBytes(_loc12_,0);
            _loc11_.writeUnsignedInt(CRC32.hash(_loc12_));
         }
         if(_loc9_ < ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH)
         {
            _loc12_.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
         }
         else
         {
            _loc12_.length = _loc9_;
         }
         ApplicationDomain.currentDomain.domainMemory = _loc12_;
         if(_loc5_)
         {
            if(_loc8_ < 1028)
            {
               _loc16_ = 1028;
               _loc15_ = _loc16_ < _loc9_ ? _loc16_ : _loc9_;
               _loc16_ = _loc15_ - _loc8_;
               _loc17_ = _loc8_;
               if(_loc16_ >= 12)
               {
                  _loc18_ = 0;
                  _loc19_ = _loc15_ - (_loc16_ & 3);
                  do
                  {
                     si32(_loc18_,_loc17_);
                  }
                  while(_loc17_ += 4, _loc17_ < _loc19_);
               }
               else
               {
                  _loc15_ = _loc8_ + _loc17_;
               }
               while(_loc17_ < _loc15_)
               {
                  var _temp_28:* = 0;
                  _loc17_ = uint((_loc18_ = uint(_loc17_)) + 1);
                  si8(_temp_28,_loc18_);
               }
            }
            _loc15_ = uint(param1.width);
            _loc16_ = uint(param1.height);
            _loc18_ = 0;
            _loc23_ = 0;
            switch(param3)
            {
               case 0:
                  do
                  {
                     var _temp_30:* = 0;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_30,_loc25_);
                     _loc17_ = 0;
                     do
                     {
                        var _temp_32:* = param2.getIndexByColor(param1.getPixel32(_loc17_,_loc18_));
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_32,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 1:
                  do
                  {
                     var _temp_36:* = 1;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_36,_loc25_);
                     _loc20_ = 0;
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel32(_loc17_,_loc18_));
                        var _temp_39:* = _loc19_ - _loc20_;
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_39,_loc25_);
                        _loc20_ = _loc19_;
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 2:
                  do
                  {
                     _loc24_ = _loc8_;
                     var _temp_43:* = 2;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_43,_loc25_);
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel32(_loc17_,_loc18_));
                        var _temp_46:* = _loc19_ - li8(_loc24_);
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_46,_loc25_);
                        var _temp_48:* = _loc19_;
                        _loc24_ = (_loc25_ = _loc24_) + 1;
                        si8(_temp_48,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 3:
                  do
                  {
                     _loc24_ = _loc8_;
                     var _temp_52:* = 3;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_52,_loc25_);
                     _loc20_ = 0;
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel32(_loc17_,_loc18_));
                        var _temp_55:* = _loc19_ - (_loc20_ + li8(_loc24_) >>> 1);
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_55,_loc25_);
                        _loc20_ = _loc19_;
                        var _temp_57:* = _loc19_;
                        _loc24_ = (_loc25_ = _loc24_) + 1;
                        si8(_temp_57,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 4:
                  while(true)
                  {
                     _loc24_ = _loc8_;
                     var _temp_61:* = 4;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_61,_loc25_);
                     _loc20_ = 0;
                     _loc22_ = 0;
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel32(_loc17_,_loc18_));
                        _loc21_ = uint(li8(_loc24_));
                        §§push(_loc19_);
                        _loc25_ = (_loc27_ = (_loc26_ = _loc20_ + _loc21_ - _loc22_) - _loc20_) < 0 ? -_loc27_ : _loc27_;
                        _loc27_ = _loc26_ - _loc21_;
                        _loc28_ = _loc27_ < 0 ? -_loc27_ : _loc27_;
                        _loc27_ = _loc26_ - _loc22_;
                        _loc29_ = _loc27_ < 0 ? -_loc27_ : _loc27_;
                        var _temp_67:* = §§pop() - (_loc25_ <= _loc28_ && _loc25_ <= _loc29_ ? _loc20_ : (_loc28_ <= _loc29_ ? _loc21_ : _loc22_));
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_67,_loc25_);
                        _loc20_ = _loc19_;
                        _loc22_ = _loc21_;
                        var _temp_69:* = _loc19_;
                        _loc24_ = (_loc25_ = _loc24_) + 1;
                        si8(_temp_69,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                     if(++_loc18_ >= _loc16_)
                     {
                        break;
                     }
                  }
            }
         }
         else
         {
            if(_loc8_ < 772)
            {
               _loc16_ = 772;
               _loc15_ = _loc16_ < _loc9_ ? _loc16_ : _loc9_;
               _loc16_ = _loc15_ - _loc8_;
               _loc17_ = _loc8_;
               if(_loc16_ >= 12)
               {
                  _loc18_ = 0;
                  _loc19_ = _loc15_ - (_loc16_ & 3);
                  do
                  {
                     si32(_loc18_,_loc17_);
                  }
                  while(_loc17_ += 4, _loc17_ < _loc19_);
               }
               else
               {
                  _loc15_ = _loc8_ + _loc17_;
               }
               while(_loc17_ < _loc15_)
               {
                  var _temp_76:* = 0;
                  _loc17_ = uint((_loc18_ = uint(_loc17_)) + 1);
                  si8(_temp_76,_loc18_);
               }
            }
            _loc15_ = uint(param1.width);
            _loc16_ = uint(param1.height);
            _loc18_ = 0;
            _loc23_ = 0;
            switch(param3)
            {
               case 0:
                  do
                  {
                     var _temp_78:* = 0;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_78,_loc25_);
                     _loc17_ = 0;
                     do
                     {
                        var _temp_80:* = param2.getIndexByColor(param1.getPixel(_loc17_,_loc18_));
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_80,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 1:
                  do
                  {
                     var _temp_84:* = 1;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_84,_loc25_);
                     _loc20_ = 0;
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel(_loc17_,_loc18_));
                        var _temp_87:* = _loc19_ - _loc20_;
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_87,_loc25_);
                        _loc20_ = _loc19_;
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 2:
                  do
                  {
                     _loc24_ = _loc8_;
                     var _temp_91:* = 2;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_91,_loc25_);
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel(_loc17_,_loc18_));
                        var _temp_94:* = _loc19_ - li8(_loc24_);
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_94,_loc25_);
                        var _temp_96:* = _loc19_;
                        _loc24_ = (_loc25_ = _loc24_) + 1;
                        si8(_temp_96,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 3:
                  do
                  {
                     _loc24_ = _loc8_;
                     var _temp_100:* = 3;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_100,_loc25_);
                     _loc20_ = 0;
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel(_loc17_,_loc18_));
                        var _temp_103:* = _loc19_ - (_loc20_ + li8(_loc24_) >>> 1);
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_103,_loc25_);
                        _loc20_ = _loc19_;
                        var _temp_105:* = _loc19_;
                        _loc24_ = (_loc25_ = _loc24_) + 1;
                        si8(_temp_105,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                  }
                  while(++_loc18_ < _loc16_);
                  break;
               case 4:
                  while(true)
                  {
                     _loc24_ = _loc8_;
                     var _temp_109:* = 4;
                     _loc23_ = (_loc25_ = _loc23_) + 1;
                     si8(_temp_109,_loc25_);
                     _loc20_ = 0;
                     _loc22_ = 0;
                     _loc17_ = 0;
                     do
                     {
                        _loc19_ = param2.getIndexByColor(param1.getPixel(_loc17_,_loc18_));
                        _loc21_ = uint(li8(_loc24_));
                        §§push(_loc19_);
                        _loc25_ = (_loc27_ = (_loc26_ = _loc20_ + _loc21_ - _loc22_) - _loc20_) < 0 ? -_loc27_ : _loc27_;
                        _loc27_ = _loc26_ - _loc21_;
                        _loc28_ = _loc27_ < 0 ? -_loc27_ : _loc27_;
                        _loc27_ = _loc26_ - _loc22_;
                        _loc29_ = _loc27_ < 0 ? -_loc27_ : _loc27_;
                        var _temp_115:* = §§pop() - (_loc25_ <= _loc28_ && _loc25_ <= _loc29_ ? _loc20_ : (_loc28_ <= _loc29_ ? _loc21_ : _loc22_));
                        _loc23_ = (_loc25_ = _loc23_) + 1;
                        si8(_temp_115,_loc25_);
                        _loc20_ = _loc19_;
                        _loc22_ = _loc21_;
                        var _temp_117:* = _loc19_;
                        _loc24_ = (_loc25_ = _loc24_) + 1;
                        si8(_temp_117,_loc25_);
                     }
                     while(++_loc17_ < _loc15_);
                     if(++_loc18_ >= _loc16_)
                     {
                        break;
                     }
                  }
            }
         }
         ApplicationDomain.currentDomain.domainMemory = _loc4_;
         _loc12_.length = _loc8_;
         _loc12_.compress();
         _loc12_.position = 4;
         _loc12_.writeBytes(_loc12_);
         _loc12_.position = 0;
         _loc12_.writeUnsignedInt(1229209940);
         _loc11_.writeUnsignedInt(_loc12_.length - 4);
         _loc11_.writeBytes(_loc12_,0);
         _loc11_.writeUnsignedInt(CRC32.hash(_loc12_));
         _loc12_.length = 0;
         _loc12_.writeUnsignedInt(1950701684);
         _loc12_.writeMultiByte("Software","latin-1");
         _loc12_.writeByte(0);
         _loc12_.writeMultiByte("by.blooddy.crypto.image.PNG8Encoder","latin-1");
         _loc11_.writeUnsignedInt(_loc12_.length - 4);
         _loc11_.writeBytes(_loc12_,0);
         _loc11_.writeUnsignedInt(CRC32.hash(_loc12_));
         _loc12_.length = 0;
         _loc12_.writeUnsignedInt(1229278788);
         _loc11_.writeUnsignedInt(_loc12_.length - 4);
         _loc11_.writeBytes(_loc12_,0);
         _loc11_.writeUnsignedInt(CRC32.hash(_loc12_));
         ApplicationDomain.currentDomain.domainMemory = _loc4_;
         _loc11_.position = 0;
         return _loc11_;
      }
   }
}

