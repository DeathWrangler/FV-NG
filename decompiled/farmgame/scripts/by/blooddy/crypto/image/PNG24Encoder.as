package by.blooddy.crypto.image
{
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import by.blooddy.crypto.CRC32;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.ByteArray;
   
   public class PNG24Encoder
   {
      
      public function PNG24Encoder()
      {
      }
      
      public static function encode(param1:BitmapData, param2:int = 0) : ByteArray
      {
         var _loc11_:* = null as ByteArray;
         var _loc12_:uint = 0;
         var _loc13_:uint = 0;
         var _loc14_:* = 0;
         var _loc15_:* = 0;
         var _loc16_:uint = 0;
         var _loc17_:uint = 0;
         var _loc18_:uint = 0;
         var _loc19_:uint = 0;
         var _loc20_:uint = 0;
         var _loc21_:uint = 0;
         var _loc22_:uint = 0;
         var _loc23_:uint = 0;
         var _loc24_:uint = 0;
         var _loc25_:uint = 0;
         var _loc26_:uint = 0;
         var _loc27_:uint = 0;
         var _loc28_:uint = 0;
         var _loc29_:uint = 0;
         var _loc30_:uint = 0;
         var _loc31_:uint = 0;
         var _loc32_:uint = 0;
         var _loc33_:uint = 0;
         var _loc34_:uint = 0;
         var _loc35_:* = null as ByteArray;
         var _loc36_:uint = 0;
         var _loc37_:* = 0;
         var _loc38_:* = 0;
         var _loc39_:uint = 0;
         var _loc40_:uint = 0;
         if(param1 == null)
         {
            Error.throwError(TypeError,2007,"image");
         }
         if(param2 < 0 || param2 > 4)
         {
            Error.throwError(ArgumentError,2008,"filter");
         }
         var _loc3_:ByteArray = ApplicationDomain.currentDomain.domainMemory;
         var _loc4_:Boolean = param1.transparent && (param1.getPixel32(0,0) < 4278190080 || (param1.getPixel32(param1.width,param1.height) < 4278190080 || (param1.getPixel32(param1.width,0) < 4278190080 || (param1.getPixel32(0,param1.height) < 4278190080 || param1.clone().threshold(param1,param1.rect,new Point(),"!=",4278190080,0,4278190080,true) != 0))));
         var _loc5_:uint = uint(param1.width);
         var _loc6_:uint = uint(param1.height);
         var _loc7_:uint = _loc5_ * _loc6_ * (_loc4_ ? 4 : 3) + _loc6_;
         var _loc8_:uint = _loc7_ + _loc5_ * 4;
         var _loc9_:ByteArray = new ByteArray();
         _loc11_ = new ByteArray();
         if(_loc8_ != 0)
         {
            _loc11_.length = _loc8_;
         }
         var _loc10_:ByteArray = _loc11_;
         _loc9_.writeUnsignedInt(-1991225785);
         _loc9_.writeUnsignedInt(218765834);
         _loc10_.length = 0;
         _loc10_.writeUnsignedInt(1229472850);
         _loc10_.writeUnsignedInt(_loc5_);
         _loc10_.writeUnsignedInt(_loc6_);
         _loc10_.writeByte(8);
         _loc10_.writeByte(_loc4_ ? 6 : 2);
         _loc10_.writeByte(0);
         _loc10_.writeByte(0);
         _loc10_.writeByte(0);
         _loc9_.writeUnsignedInt(_loc10_.length - 4);
         _loc9_.writeBytes(_loc10_,0);
         _loc9_.writeUnsignedInt(CRC32.hash(_loc10_));
         if(_loc8_ < 1024)
         {
            _loc10_.length = 1024;
         }
         else
         {
            _loc10_.length = _loc8_;
         }
         ApplicationDomain.currentDomain.domainMemory = _loc10_;
         if(_loc7_ < 17)
         {
            _loc12_ = 17;
            _loc13_ = _loc12_ - _loc7_;
            _loc14_ = _loc7_;
            if(_loc13_ >= 12)
            {
               _loc15_ = 0;
               _loc16_ = _loc12_ - (_loc13_ & 3);
               do
               {
                  si32(_loc15_,_loc14_);
               }
               while(_loc14_ += 4, _loc14_ < _loc16_);
            }
            else
            {
               _loc12_ = _loc7_ + _loc14_;
            }
            while(_loc14_ < _loc12_)
            {
               var _temp_5:* = 0;
               _loc14_ = uint((_loc15_ = uint(_loc14_)) + 1);
               si8(_temp_5,_loc15_);
            }
         }
         if(_loc4_)
         {
            _loc12_ = uint(param1.width);
            _loc13_ = uint(param1.height);
            _loc15_ = 0;
            _loc17_ = 0;
            _loc32_ = 0;
            _loc34_ = 0;
            switch(param2)
            {
               case 0:
                  if(_loc12_ >= 64)
                  {
                     _loc12_ <<= 2;
                     _loc11_ = param1.getPixels(param1.rect);
                     _loc35_ = ApplicationDomain.currentDomain.domainMemory;
                     _loc35_.position = 0;
                     _loc14_ = 0;
                     do
                     {
                        _loc35_.writeBytes(_loc11_,_loc15_ * _loc12_,_loc12_);
                        _loc17_ = _loc14_ + _loc12_;
                        do
                        {
                           si8(li8(_loc17_ - 4),_loc17_);
                        }
                        while(_loc17_ -= 4, _loc17_ > _loc14_);
                        si8(0,_loc14_);
                        _loc14_ += _loc12_ + 1;
                        ++_loc35_.position;
                     }
                     while(++_loc15_ < _loc13_);
                  }
                  else
                  {
                     do
                     {
                        var _temp_10:* = 0;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_10,_loc36_);
                        _loc14_ = 0;
                        do
                        {
                           _loc16_ = param1.getPixel32(_loc14_,_loc15_);
                           var _temp_13:* = _loc16_ >> 16;
                           _loc17_ = (_loc36_ = _loc17_) + 1;
                           si8(_temp_13,_loc36_);
                           var _temp_15:* = _loc16_ >> 8;
                           _loc17_ = (_loc36_ = _loc17_) + 1;
                           si8(_temp_15,_loc36_);
                           var _temp_17:* = _loc16_;
                           _loc17_ = (_loc36_ = _loc17_) + 1;
                           si8(_temp_17,_loc36_);
                           var _temp_19:* = _loc16_ >> 24;
                           _loc17_ = (_loc36_ = _loc17_) + 1;
                           si8(_temp_19,_loc36_);
                        }
                        while(++_loc14_ < _loc12_);
                     }
                     while(++_loc15_ < _loc13_);
                  }
                  break;
               case 1:
                  do
                  {
                     var _temp_23:* = 1;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_23,_loc36_);
                     _loc32_ = 0;
                     _loc22_ = 0;
                     _loc23_ = 0;
                     _loc24_ = 0;
                     _loc14_ = 0;
                     do
                     {
                        _loc21_ = param1.getPixel32(_loc14_,_loc15_);
                        _loc19_ = uint(_loc21_ >>> 16);
                        var _temp_27:* = _loc19_ - _loc22_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_27,_loc36_);
                        _loc22_ = _loc19_;
                        _loc20_ = uint(_loc21_ >>> 8);
                        var _temp_30:* = _loc20_ - _loc23_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_30,_loc36_);
                        _loc23_ = _loc20_;
                        var _temp_32:* = _loc21_ - _loc24_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_32,_loc36_);
                        _loc24_ = _loc21_;
                        _loc31_ = uint(_loc21_ >>> 24);
                        var _temp_35:* = _loc31_ - _loc32_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_35,_loc36_);
                        _loc32_ = _loc31_;
                     }
                     while(++_loc14_ < _loc12_);
                  }
                  while(++_loc15_ < _loc13_);
                  break;
               case 2:
                  do
                  {
                     _loc18_ = _loc7_;
                     var _temp_39:* = 2;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_39,_loc36_);
                     _loc14_ = 0;
                     do
                     {
                        _loc16_ = param1.getPixel32(_loc14_,_loc15_);
                        var _temp_42:* = (_loc16_ >>> 16) - li8(_loc18_ + 2);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_42,_loc36_);
                        var _temp_44:* = (_loc16_ >>> 8) - li8(_loc18_ + 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_44,_loc36_);
                        var _temp_46:* = _loc16_ - li8(_loc18_);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_46,_loc36_);
                        var _temp_48:* = (_loc16_ >>> 24) - li8(_loc18_ + 3);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_48,_loc36_);
                        si32(_loc16_,_loc18_);
                        _loc18_ += 4;
                     }
                     while(++_loc14_ < _loc12_);
                  }
                  while(++_loc15_ < _loc13_);
                  break;
               case 3:
                  do
                  {
                     _loc18_ = _loc7_;
                     var _temp_52:* = 3;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_52,_loc36_);
                     _loc32_ = 0;
                     _loc22_ = 0;
                     _loc23_ = 0;
                     _loc24_ = 0;
                     _loc14_ = 0;
                     do
                     {
                        _loc16_ = param1.getPixel32(_loc14_,_loc15_);
                        _loc19_ = uint(_loc16_ >> 16 & 0xFF);
                        var _temp_56:* = _loc19_ - (_loc22_ + li8(_loc18_ + 2) >>> 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_56,_loc36_);
                        _loc22_ = _loc19_;
                        _loc20_ = uint(_loc16_ >> 8 & 0xFF);
                        var _temp_59:* = _loc20_ - (_loc23_ + li8(_loc18_ + 1) >>> 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_59,_loc36_);
                        _loc23_ = _loc20_;
                        _loc21_ = uint(_loc16_ & 0xFF);
                        var _temp_62:* = _loc21_ - (_loc24_ + li8(_loc18_) >>> 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_62,_loc36_);
                        _loc24_ = _loc21_;
                        _loc31_ = uint(_loc16_ >>> 24);
                        var _temp_65:* = _loc31_ - (_loc32_ + li8(_loc18_ + 3) >>> 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_65,_loc36_);
                        _loc32_ = _loc31_;
                        si32(_loc16_,_loc18_);
                        _loc18_ += 4;
                     }
                     while(++_loc14_ < _loc12_);
                  }
                  while(++_loc15_ < _loc13_);
                  break;
               case 4:
                  while(true)
                  {
                     _loc18_ = _loc7_;
                     var _temp_69:* = 4;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_69,_loc36_);
                     _loc32_ = 0;
                     _loc34_ = 0;
                     _loc22_ = 0;
                     _loc28_ = 0;
                     _loc23_ = 0;
                     _loc29_ = 0;
                     _loc24_ = 0;
                     _loc30_ = 0;
                     _loc14_ = 0;
                     do
                     {
                        _loc16_ = param1.getPixel32(_loc14_,_loc15_);
                        _loc19_ = uint(_loc16_ >> 16 & 0xFF);
                        _loc25_ = uint(li8(_loc18_ + 2));
                        §§push(_loc19_);
                        _loc36_ = (_loc38_ = (_loc37_ = _loc22_ + _loc25_ - _loc28_) - _loc22_) < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc25_;
                        _loc39_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc28_;
                        _loc40_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        var _temp_76:* = §§pop() - (_loc36_ <= _loc39_ && _loc36_ <= _loc40_ ? _loc22_ : (_loc39_ <= _loc40_ ? _loc25_ : _loc28_));
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_76,_loc36_);
                        _loc22_ = _loc19_;
                        _loc28_ = _loc25_;
                        _loc20_ = uint(_loc16_ >> 8 & 0xFF);
                        _loc26_ = uint(li8(_loc18_ + 1));
                        §§push(_loc20_);
                        _loc36_ = (_loc38_ = (_loc37_ = _loc23_ + _loc26_ - _loc29_) - _loc23_) < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc26_;
                        _loc39_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc29_;
                        _loc40_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        var _temp_82:* = §§pop() - (_loc36_ <= _loc39_ && _loc36_ <= _loc40_ ? _loc23_ : (_loc39_ <= _loc40_ ? _loc26_ : _loc29_));
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_82,_loc36_);
                        _loc23_ = _loc20_;
                        _loc29_ = _loc26_;
                        _loc21_ = uint(_loc16_ & 0xFF);
                        _loc27_ = uint(li8(_loc18_));
                        §§push(_loc21_);
                        _loc36_ = (_loc38_ = (_loc37_ = _loc24_ + _loc27_ - _loc30_) - _loc24_) < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc27_;
                        _loc39_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc30_;
                        _loc40_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        var _temp_88:* = §§pop() - (_loc36_ <= _loc39_ && _loc36_ <= _loc40_ ? _loc24_ : (_loc39_ <= _loc40_ ? _loc27_ : _loc30_));
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_88,_loc36_);
                        _loc24_ = _loc21_;
                        _loc30_ = _loc27_;
                        _loc31_ = uint(_loc16_ >>> 24);
                        _loc33_ = uint(li8(_loc18_ + 3));
                        §§push(_loc31_);
                        _loc36_ = (_loc38_ = (_loc37_ = _loc32_ + _loc33_ - _loc34_) - _loc32_) < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc33_;
                        _loc39_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc34_;
                        _loc40_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        var _temp_94:* = §§pop() - (_loc36_ <= _loc39_ && _loc36_ <= _loc40_ ? _loc32_ : (_loc39_ <= _loc40_ ? _loc33_ : _loc34_));
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_94,_loc36_);
                        _loc32_ = _loc31_;
                        _loc34_ = _loc33_;
                        si32(_loc16_,_loc18_);
                        _loc18_ += 4;
                     }
                     while(++_loc14_ < _loc12_);
                     if(++_loc15_ >= _loc13_)
                     {
                        break;
                     }
                  }
            }
         }
         else
         {
            _loc12_ = uint(param1.width);
            _loc13_ = uint(param1.height);
            _loc15_ = 0;
            _loc17_ = 0;
            _loc32_ = 0;
            _loc34_ = 0;
            switch(param2)
            {
               case 0:
                  do
                  {
                     var _temp_98:* = 0;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_98,_loc36_);
                     _loc14_ = 0;
                     do
                     {
                        _loc16_ = param1.getPixel(_loc14_,_loc15_);
                        var _temp_101:* = _loc16_ >> 16;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_101,_loc36_);
                        var _temp_103:* = _loc16_ >> 8;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_103,_loc36_);
                        var _temp_105:* = _loc16_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_105,_loc36_);
                     }
                     while(++_loc14_ < _loc12_);
                  }
                  while(++_loc15_ < _loc13_);
                  break;
               case 1:
                  do
                  {
                     var _temp_109:* = 1;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_109,_loc36_);
                     _loc22_ = 0;
                     _loc23_ = 0;
                     _loc24_ = 0;
                     _loc14_ = 0;
                     do
                     {
                        _loc21_ = param1.getPixel(_loc14_,_loc15_);
                        _loc19_ = uint(_loc21_ >>> 16);
                        var _temp_113:* = _loc19_ - _loc22_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_113,_loc36_);
                        _loc22_ = _loc19_;
                        _loc20_ = uint(_loc21_ >>> 8);
                        var _temp_116:* = _loc20_ - _loc23_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_116,_loc36_);
                        _loc23_ = _loc20_;
                        var _temp_118:* = _loc21_ - _loc24_;
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_118,_loc36_);
                        _loc24_ = _loc21_;
                     }
                     while(++_loc14_ < _loc12_);
                  }
                  while(++_loc15_ < _loc13_);
                  break;
               case 2:
                  do
                  {
                     _loc18_ = _loc7_;
                     var _temp_122:* = 2;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_122,_loc36_);
                     _loc14_ = 0;
                     do
                     {
                        _loc16_ = param1.getPixel(_loc14_,_loc15_);
                        var _temp_125:* = (_loc16_ >>> 16) - li8(_loc18_ + 2);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_125,_loc36_);
                        var _temp_127:* = (_loc16_ >>> 8) - li8(_loc18_ + 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_127,_loc36_);
                        var _temp_129:* = _loc16_ - li8(_loc18_);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_129,_loc36_);
                        si32(_loc16_,_loc18_);
                        _loc18_ += 4;
                     }
                     while(++_loc14_ < _loc12_);
                  }
                  while(++_loc15_ < _loc13_);
                  break;
               case 3:
                  do
                  {
                     _loc18_ = _loc7_;
                     var _temp_133:* = 3;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_133,_loc36_);
                     _loc22_ = 0;
                     _loc23_ = 0;
                     _loc24_ = 0;
                     _loc14_ = 0;
                     do
                     {
                        _loc16_ = param1.getPixel(_loc14_,_loc15_);
                        _loc19_ = uint(_loc16_ >>> 16);
                        var _temp_137:* = _loc19_ - (_loc22_ + li8(_loc18_ + 2) >>> 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_137,_loc36_);
                        _loc22_ = _loc19_;
                        _loc20_ = uint(_loc16_ >> 8 & 0xFF);
                        var _temp_140:* = _loc20_ - (_loc23_ + li8(_loc18_ + 1) >>> 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_140,_loc36_);
                        _loc23_ = _loc20_;
                        _loc21_ = uint(_loc16_ & 0xFF);
                        var _temp_143:* = _loc21_ - (_loc24_ + li8(_loc18_) >>> 1);
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_143,_loc36_);
                        _loc24_ = _loc21_;
                        si32(_loc16_,_loc18_);
                        _loc18_ += 4;
                     }
                     while(++_loc14_ < _loc12_);
                  }
                  while(++_loc15_ < _loc13_);
                  break;
               case 4:
                  while(true)
                  {
                     _loc18_ = _loc7_;
                     var _temp_147:* = 4;
                     _loc17_ = (_loc36_ = _loc17_) + 1;
                     si8(_temp_147,_loc36_);
                     _loc22_ = 0;
                     _loc28_ = 0;
                     _loc23_ = 0;
                     _loc29_ = 0;
                     _loc24_ = 0;
                     _loc30_ = 0;
                     _loc14_ = 0;
                     do
                     {
                        _loc16_ = param1.getPixel(_loc14_,_loc15_);
                        _loc19_ = uint(_loc16_ >>> 16);
                        _loc25_ = uint(li8(_loc18_ + 2));
                        §§push(_loc19_);
                        _loc36_ = (_loc38_ = (_loc37_ = _loc22_ + _loc25_ - _loc28_) - _loc22_) < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc25_;
                        _loc39_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc28_;
                        _loc40_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        var _temp_154:* = §§pop() - (_loc36_ <= _loc39_ && _loc36_ <= _loc40_ ? _loc22_ : (_loc39_ <= _loc40_ ? _loc25_ : _loc28_));
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_154,_loc36_);
                        _loc22_ = _loc19_;
                        _loc28_ = _loc25_;
                        _loc20_ = uint(_loc16_ >> 8 & 0xFF);
                        _loc26_ = uint(li8(_loc18_ + 1));
                        §§push(_loc20_);
                        _loc36_ = (_loc38_ = (_loc37_ = _loc23_ + _loc26_ - _loc29_) - _loc23_) < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc26_;
                        _loc39_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc29_;
                        _loc40_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        var _temp_160:* = §§pop() - (_loc36_ <= _loc39_ && _loc36_ <= _loc40_ ? _loc23_ : (_loc39_ <= _loc40_ ? _loc26_ : _loc29_));
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_160,_loc36_);
                        _loc23_ = _loc20_;
                        _loc29_ = _loc26_;
                        _loc21_ = uint(_loc16_ & 0xFF);
                        _loc27_ = uint(li8(_loc18_));
                        §§push(_loc21_);
                        _loc36_ = (_loc38_ = (_loc37_ = _loc24_ + _loc27_ - _loc30_) - _loc24_) < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc27_;
                        _loc39_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        _loc38_ = _loc37_ - _loc30_;
                        _loc40_ = _loc38_ < 0 ? -_loc38_ : _loc38_;
                        var _temp_166:* = §§pop() - (_loc36_ <= _loc39_ && _loc36_ <= _loc40_ ? _loc24_ : (_loc39_ <= _loc40_ ? _loc27_ : _loc30_));
                        _loc17_ = (_loc36_ = _loc17_) + 1;
                        si8(_temp_166,_loc36_);
                        _loc24_ = _loc21_;
                        _loc30_ = _loc27_;
                        si32(_loc16_,_loc18_);
                        _loc18_ += 4;
                     }
                     while(++_loc14_ < _loc12_);
                     if(++_loc15_ >= _loc13_)
                     {
                        break;
                     }
                  }
            }
         }
         ApplicationDomain.currentDomain.domainMemory = _loc3_;
         _loc10_.length = _loc7_;
         _loc10_.compress();
         _loc10_.position = 4;
         _loc10_.writeBytes(_loc10_);
         _loc10_.position = 0;
         _loc10_.writeUnsignedInt(1229209940);
         _loc9_.writeUnsignedInt(_loc10_.length - 4);
         _loc9_.writeBytes(_loc10_,0);
         _loc9_.writeUnsignedInt(CRC32.hash(_loc10_));
         _loc10_.length = 0;
         _loc10_.writeUnsignedInt(1950701684);
         _loc10_.writeMultiByte("Software","latin-1");
         _loc10_.writeByte(0);
         _loc10_.writeMultiByte("by.blooddy.crypto.image.PNG24Encoder","latin-1");
         _loc9_.writeUnsignedInt(_loc10_.length - 4);
         _loc9_.writeBytes(_loc10_,0);
         _loc9_.writeUnsignedInt(CRC32.hash(_loc10_));
         _loc10_.length = 0;
         _loc10_.writeUnsignedInt(1229278788);
         _loc9_.writeUnsignedInt(_loc10_.length - 4);
         _loc9_.writeBytes(_loc10_,0);
         _loc9_.writeUnsignedInt(CRC32.hash(_loc10_));
         _loc9_.position = 0;
         return _loc9_;
      }
   }
}

