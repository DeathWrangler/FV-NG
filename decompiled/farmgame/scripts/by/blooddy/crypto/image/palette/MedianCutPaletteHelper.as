package by.blooddy.crypto.image.palette
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.ByteArray;
   
   public class MedianCutPaletteHelper
   {
      
      public function MedianCutPaletteHelper()
      {
      }
      
      public static function createTable(param1:BitmapData, param2:uint = 256) : Array
      {
         var _loc3_:* = null as ByteArray;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         var _loc9_:* = null as ByteArray;
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc13_:* = 0;
         var _loc14_:* = 0;
         var _loc15_:uint = 0;
         var _loc16_:uint = 0;
         var _loc17_:uint = 0;
         var _loc18_:uint = 0;
         var _loc19_:uint = 0;
         var _loc20_:uint = 0;
         var _loc21_:uint = 0;
         var _loc22_:uint = 0;
         var _loc23_:* = 0;
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
         var _loc35_:uint = 0;
         var _loc36_:uint = 0;
         var _loc37_:uint = 0;
         var _loc38_:uint = 0;
         var _loc39_:uint = 0;
         var _loc40_:uint = 0;
         var _loc41_:uint = 0;
         var _loc42_:uint = 0;
         var _loc43_:uint = 0;
         var _loc44_:uint = 0;
         var _loc45_:uint = 0;
         var _loc46_:uint = 0;
         var _loc47_:* = null as Array;
         var _loc48_:* = null as Vector.<uint>;
         if(param1 == null)
         {
            Error.throwError(TypeError,2007,"image");
         }
         if(param2 < 2 || param2 > 256)
         {
            Error.throwError(RangeError,2006);
         }
         if(param1.transparent && (param1.getPixel32(0,0) < 4278190080 || (param1.getPixel32(param1.width,param1.height) < 4278190080 || (param1.getPixel32(param1.width,0) < 4278190080 || (param1.getPixel32(0,param1.height) < 4278190080 || param1.clone().threshold(param1,param1.rect,new Point(),"!=",4278190080,0,4278190080,true) != 0)))))
         {
            _loc3_ = ApplicationDomain.currentDomain.domainMemory;
            _loc4_ = uint(param1.width);
            _loc5_ = uint(param1.height);
            _loc6_ = uint(_loc4_ * _loc5_ << 2);
            _loc7_ = 25 * param2;
            _loc8_ = 0;
            _loc9_ = new ByteArray();
            _loc9_.length = _loc7_ + _loc6_;
            if(_loc9_.length < ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH)
            {
               _loc9_.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
            }
            ApplicationDomain.currentDomain.domainMemory = _loc9_;
            _loc11_ = uint(~param1.getPixel32(0,0));
            _loc14_ = 0;
            _loc15_ = uint(-16777216);
            _loc16_ = 0;
            _loc17_ = 16711680;
            _loc18_ = 0;
            _loc19_ = 65280;
            _loc20_ = 0;
            _loc21_ = 255;
            _loc22_ = 0;
            _loc23_ = _loc7_;
            do
            {
               _loc13_ = 0;
               do
               {
                  _loc10_ = param1.getPixel32(_loc13_,_loc14_);
                  if(_loc10_ != _loc11_)
                  {
                     _loc11_ = _loc10_;
                     _loc12_ = uint(_loc10_ & -16777216);
                     if(_loc12_ < _loc15_)
                     {
                        _loc15_ = _loc12_;
                     }
                     if(_loc12_ > _loc16_)
                     {
                        _loc16_ = _loc12_;
                     }
                     _loc12_ = uint(_loc10_ & 0xFF0000);
                     if(_loc12_ < _loc17_)
                     {
                        _loc17_ = _loc12_;
                     }
                     if(_loc12_ > _loc18_)
                     {
                        _loc18_ = _loc12_;
                     }
                     _loc12_ = uint(_loc10_ & 0xFF00);
                     if(_loc12_ < _loc19_)
                     {
                        _loc19_ = _loc12_;
                     }
                     if(_loc12_ > _loc20_)
                     {
                        _loc20_ = _loc12_;
                     }
                     _loc12_ = uint(_loc10_ & 0xFF);
                     if(_loc12_ < _loc21_)
                     {
                        _loc21_ = _loc12_;
                     }
                     if(_loc12_ > _loc22_)
                     {
                        _loc22_ = _loc12_;
                     }
                     si32(_loc10_,_loc23_);
                     _loc23_ += 4;
                  }
               }
               while(++_loc13_ < _loc4_);
            }
            while(++_loc14_ < _loc5_);
            _loc24_ = uint((_loc16_ + _loc15_) / 2 & -16777216);
            _loc25_ = 0;
            _loc26_ = 0;
            _loc27_ = 0;
            _loc28_ = 0;
            _loc29_ = 0;
            _loc30_ = 0;
            if(_loc24_ > 0)
            {
               _loc25_ = uint(_loc18_ + _loc17_ >>> 1 & 0xFF0000);
               _loc26_ = uint(_loc20_ + _loc19_ >>> 1 & 0xFF00);
               _loc27_ = uint(_loc22_ + _loc21_ >>> 1 & 0xFF);
               _loc31_ = _loc22_ - _loc21_;
               if(_loc31_ > _loc28_)
               {
                  _loc28_ = _loc31_;
                  _loc29_ = _loc27_;
                  _loc30_ = 255;
               }
               _loc31_ = uint(_loc20_ - _loc19_ >>> 8);
               if(_loc31_ > _loc28_)
               {
                  _loc28_ = _loc31_;
                  _loc29_ = _loc26_;
                  _loc30_ = 65280;
               }
               _loc31_ = uint(_loc18_ - _loc17_ >>> 16);
               if(_loc31_ > _loc28_)
               {
                  _loc28_ = _loc31_;
                  _loc29_ = _loc25_;
                  _loc30_ = 16711680;
               }
               _loc31_ = uint(_loc16_ - _loc15_ >>> 24);
               if(_loc31_ > _loc28_)
               {
                  _loc28_ = _loc31_;
                  _loc29_ = _loc24_;
                  _loc30_ = uint(-16777216);
               }
            }
            _loc31_ = 0;
            _loc33_ = _loc8_;
            _loc8_ = _loc33_ + 1;
            _loc32_ = _loc33_ * 25;
            while(_loc31_ < _loc32_)
            {
               if(_loc28_ < li8(_loc31_))
               {
                  _loc9_.position = _loc31_ + 25;
                  _loc9_.writeBytes(_loc9_,_loc31_,_loc32_ - _loc31_);
                  break;
               }
               _loc31_ += 25;
            }
            si8(_loc28_,_loc31_);
            si32(_loc30_,_loc31_ + 1);
            si32(_loc24_ | _loc25_ | _loc26_ | _loc27_,_loc31_ + 5);
            si32(_loc15_ | _loc17_ | _loc19_ | _loc21_,_loc31_ + 9);
            si32(_loc16_ | _loc18_ | _loc20_ | _loc22_,_loc31_ + 13);
            si32(_loc7_,_loc31_ + 17);
            si32(_loc23_ - _loc7_,_loc31_ + 21);
            _loc7_ = _loc23_;
            if(li8(0) > 0)
            {
               _loc26_ = uint(-16777216);
               _loc27_ = 0;
               while(_loc8_ < param2 && li8(_loc8_ * 25 - 25) > 1)
               {
                  _loc8_--;
                  _loc15_ = uint(-16777216);
                  _loc16_ = 0;
                  _loc26_ = uint(-16777216);
                  _loc27_ = 0;
                  _loc17_ = 16711680;
                  _loc18_ = 0;
                  _loc28_ = 16711680;
                  _loc29_ = 0;
                  _loc21_ = 255;
                  _loc22_ = 0;
                  _loc32_ = 255;
                  _loc33_ = 0;
                  _loc19_ = 65280;
                  _loc20_ = 0;
                  _loc30_ = 65280;
                  _loc31_ = 0;
                  _loc36_ = _loc8_ * 25;
                  _loc34_ = uint(li32(_loc36_ + 1));
                  _loc35_ = uint(li32(_loc36_ + 5) & _loc34_);
                  _loc23_ = uint(li32(_loc36_ + 17));
                  _loc6_ = uint(li32(_loc36_ + 21));
                  _loc24_ = _loc7_;
                  _loc7_ += _loc6_;
                  _loc13_ = _loc24_;
                  _loc14_ = _loc7_;
                  _loc6_ += _loc23_;
                  if(_loc7_ > 1024)
                  {
                     _loc9_.length = _loc7_;
                  }
                  _loc11_ = uint(~li32(_loc23_));
                  do
                  {
                     _loc10_ = uint(li32(_loc23_));
                     _loc23_ += 4;
                     if(_loc10_ != _loc11_)
                     {
                        _loc11_ = _loc10_;
                        _loc25_ = uint(_loc10_ & _loc34_);
                        if(_loc25_ <= _loc35_)
                        {
                           _loc12_ = uint(_loc10_ & -16777216);
                           if(_loc12_ < _loc15_)
                           {
                              _loc15_ = _loc12_;
                           }
                           if(_loc12_ > _loc16_)
                           {
                              _loc16_ = _loc12_;
                           }
                           _loc12_ = uint(_loc10_ & 0xFF0000);
                           if(_loc12_ < _loc17_)
                           {
                              _loc17_ = _loc12_;
                           }
                           if(_loc12_ > _loc18_)
                           {
                              _loc18_ = _loc12_;
                           }
                           _loc12_ = uint(_loc10_ & 0xFF00);
                           if(_loc12_ < _loc19_)
                           {
                              _loc19_ = _loc12_;
                           }
                           if(_loc12_ > _loc20_)
                           {
                              _loc20_ = _loc12_;
                           }
                           _loc12_ = uint(_loc10_ & 0xFF);
                           if(_loc12_ < _loc21_)
                           {
                              _loc21_ = _loc12_;
                           }
                           if(_loc12_ > _loc22_)
                           {
                              _loc22_ = _loc12_;
                           }
                           si32(_loc10_,_loc13_);
                           _loc13_ += 4;
                        }
                        else
                        {
                           _loc12_ = uint(_loc10_ & -16777216);
                           if(_loc12_ < _loc26_)
                           {
                              _loc26_ = _loc12_;
                           }
                           if(_loc12_ > _loc27_)
                           {
                              _loc27_ = _loc12_;
                           }
                           _loc12_ = uint(_loc10_ & 0xFF0000);
                           if(_loc12_ < _loc28_)
                           {
                              _loc28_ = _loc12_;
                           }
                           if(_loc12_ > _loc29_)
                           {
                              _loc29_ = _loc12_;
                           }
                           _loc12_ = uint(_loc10_ & 0xFF00);
                           if(_loc12_ < _loc30_)
                           {
                              _loc30_ = _loc12_;
                           }
                           if(_loc12_ > _loc31_)
                           {
                              _loc31_ = _loc12_;
                           }
                           _loc12_ = uint(_loc10_ & 0xFF);
                           if(_loc12_ < _loc32_)
                           {
                              _loc32_ = _loc12_;
                           }
                           if(_loc12_ > _loc33_)
                           {
                              _loc33_ = _loc12_;
                           }
                           _loc14_ -= 4;
                           si32(_loc10_,_loc14_);
                        }
                     }
                  }
                  while(_loc23_ < _loc6_);
                  _loc37_ = uint((_loc16_ + _loc15_) / 2 & -16777216);
                  _loc38_ = 0;
                  _loc39_ = 0;
                  _loc40_ = 0;
                  _loc41_ = 0;
                  _loc42_ = 0;
                  _loc43_ = 0;
                  if(_loc37_ > 0)
                  {
                     _loc38_ = uint(_loc18_ + _loc17_ >>> 1 & 0xFF0000);
                     _loc39_ = uint(_loc20_ + _loc19_ >>> 1 & 0xFF00);
                     _loc40_ = uint(_loc22_ + _loc21_ >>> 1 & 0xFF);
                     _loc44_ = _loc22_ - _loc21_;
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc40_;
                        _loc43_ = 255;
                     }
                     _loc44_ = uint(_loc20_ - _loc19_ >>> 8);
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc39_;
                        _loc43_ = 65280;
                     }
                     _loc44_ = uint(_loc18_ - _loc17_ >>> 16);
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc38_;
                        _loc43_ = 16711680;
                     }
                     _loc44_ = uint(_loc16_ - _loc15_ >>> 24);
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc37_;
                        _loc43_ = uint(-16777216);
                     }
                  }
                  _loc44_ = 0;
                  _loc46_ = _loc8_;
                  _loc8_ = _loc46_ + 1;
                  _loc45_ = _loc46_ * 25;
                  while(_loc44_ < _loc45_)
                  {
                     if(_loc41_ < li8(_loc44_))
                     {
                        _loc9_.position = _loc44_ + 25;
                        _loc9_.writeBytes(_loc9_,_loc44_,_loc45_ - _loc44_);
                        break;
                     }
                     _loc44_ += 25;
                  }
                  si8(_loc41_,_loc44_);
                  si32(_loc43_,_loc44_ + 1);
                  si32(_loc37_ | _loc38_ | _loc39_ | _loc40_,_loc44_ + 5);
                  si32(_loc15_ | _loc17_ | _loc19_ | _loc21_,_loc44_ + 9);
                  si32(_loc16_ | _loc18_ | _loc20_ | _loc22_,_loc44_ + 13);
                  si32(_loc24_,_loc44_ + 17);
                  si32(_loc13_ - _loc24_,_loc44_ + 21);
                  _loc37_ = uint((_loc27_ + _loc26_) / 2 & -16777216);
                  _loc38_ = 0;
                  _loc39_ = 0;
                  _loc40_ = 0;
                  _loc41_ = 0;
                  _loc42_ = 0;
                  _loc43_ = 0;
                  if(_loc37_ > 0)
                  {
                     _loc38_ = uint(_loc29_ + _loc28_ >>> 1 & 0xFF0000);
                     _loc39_ = uint(_loc31_ + _loc30_ >>> 1 & 0xFF00);
                     _loc40_ = uint(_loc33_ + _loc32_ >>> 1 & 0xFF);
                     _loc44_ = _loc33_ - _loc32_;
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc40_;
                        _loc43_ = 255;
                     }
                     _loc44_ = uint(_loc31_ - _loc30_ >>> 8);
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc39_;
                        _loc43_ = 65280;
                     }
                     _loc44_ = uint(_loc29_ - _loc28_ >>> 16);
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc38_;
                        _loc43_ = 16711680;
                     }
                     _loc44_ = uint(_loc27_ - _loc26_ >>> 24);
                     if(_loc44_ > _loc41_)
                     {
                        _loc41_ = _loc44_;
                        _loc42_ = _loc37_;
                        _loc43_ = uint(-16777216);
                     }
                  }
                  _loc44_ = 0;
                  _loc46_ = _loc8_;
                  _loc8_ = _loc46_ + 1;
                  _loc45_ = _loc46_ * 25;
                  while(_loc44_ < _loc45_)
                  {
                     if(_loc41_ < li8(_loc44_))
                     {
                        _loc9_.position = _loc44_ + 25;
                        _loc9_.writeBytes(_loc9_,_loc44_,_loc45_ - _loc44_);
                        break;
                     }
                     _loc44_ += 25;
                  }
                  si8(_loc41_,_loc44_);
                  si32(_loc43_,_loc44_ + 1);
                  si32(_loc37_ | _loc38_ | _loc39_ | _loc40_,_loc44_ + 5);
                  si32(_loc26_ | _loc28_ | _loc30_ | _loc32_,_loc44_ + 9);
                  si32(_loc27_ | _loc29_ | _loc31_ | _loc33_,_loc44_ + 13);
                  si32(_loc14_,_loc44_ + 17);
                  si32(_loc7_ - _loc14_,_loc44_ + 21);
               }
            }
            _loc14_ = 0;
            _loc47_ = [];
            _loc48_ = new Vector.<uint>();
            _loc6_ = _loc8_ * 25;
            _loc23_ = 0;
            do
            {
               _loc12_ = _loc23_ * 25;
               _loc48_.push(li32(_loc12_ + 5));
               _loc13_ = uint(li32(_loc12_ + 17));
               _loc7_ = li32(_loc12_ + 21) + _loc13_;
               do
               {
                  _loc14_++;
                  _loc47_[li32(_loc13_) >>> 0] = _loc23_;
               }
               while(_loc13_ += 4, _loc13_ < _loc7_);
            }
            while(++_loc23_ < _loc8_);
            ApplicationDomain.currentDomain.domainMemory = _loc3_;
            return [_loc48_,_loc47_];
         }
         _loc3_ = ApplicationDomain.currentDomain.domainMemory;
         _loc4_ = uint(param1.width);
         _loc5_ = uint(param1.height);
         _loc6_ = uint(_loc4_ * _loc5_ << 2);
         _loc7_ = 25 * param2;
         _loc8_ = 0;
         _loc9_ = new ByteArray();
         _loc9_.length = _loc7_ + _loc6_;
         if(_loc9_.length < ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH)
         {
            _loc9_.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
         }
         ApplicationDomain.currentDomain.domainMemory = _loc9_;
         _loc11_ = uint(~param1.getPixel(0,0));
         _loc14_ = 0;
         _loc15_ = uint(-16777216);
         _loc16_ = uint(-16777216);
         _loc17_ = 16711680;
         _loc18_ = 0;
         _loc19_ = 65280;
         _loc20_ = 0;
         _loc21_ = 255;
         _loc22_ = 0;
         _loc23_ = _loc7_;
         do
         {
            _loc13_ = 0;
            do
            {
               _loc10_ = param1.getPixel(_loc13_,_loc14_);
               if(_loc10_ != _loc11_)
               {
                  _loc11_ = _loc10_;
                  _loc12_ = uint(_loc10_ & 0xFF0000);
                  if(_loc12_ < _loc17_)
                  {
                     _loc17_ = _loc12_;
                  }
                  if(_loc12_ > _loc18_)
                  {
                     _loc18_ = _loc12_;
                  }
                  _loc12_ = uint(_loc10_ & 0xFF00);
                  if(_loc12_ < _loc19_)
                  {
                     _loc19_ = _loc12_;
                  }
                  if(_loc12_ > _loc20_)
                  {
                     _loc20_ = _loc12_;
                  }
                  _loc12_ = uint(_loc10_ & 0xFF);
                  if(_loc12_ < _loc21_)
                  {
                     _loc21_ = _loc12_;
                  }
                  if(_loc12_ > _loc22_)
                  {
                     _loc22_ = _loc12_;
                  }
                  si32(_loc10_,_loc23_);
                  _loc23_ += 4;
               }
            }
            while(++_loc13_ < _loc4_);
         }
         while(++_loc14_ < _loc5_);
         _loc24_ = uint(-16777216);
         _loc25_ = 0;
         _loc26_ = 0;
         _loc27_ = 0;
         _loc28_ = 0;
         _loc29_ = 0;
         _loc30_ = 0;
         if(_loc24_ > 0)
         {
            _loc25_ = uint(_loc18_ + _loc17_ >>> 1 & 0xFF0000);
            _loc26_ = uint(_loc20_ + _loc19_ >>> 1 & 0xFF00);
            _loc27_ = uint(_loc22_ + _loc21_ >>> 1 & 0xFF);
            _loc31_ = _loc22_ - _loc21_;
            if(_loc31_ > _loc28_)
            {
               _loc28_ = _loc31_;
               _loc29_ = _loc27_;
               _loc30_ = 255;
            }
            _loc31_ = uint(_loc20_ - _loc19_ >>> 8);
            if(_loc31_ > _loc28_)
            {
               _loc28_ = _loc31_;
               _loc29_ = _loc26_;
               _loc30_ = 65280;
            }
            _loc31_ = uint(_loc18_ - _loc17_ >>> 16);
            if(_loc31_ > _loc28_)
            {
               _loc28_ = _loc31_;
               _loc29_ = _loc25_;
               _loc30_ = 16711680;
            }
         }
         _loc31_ = 0;
         _loc33_ = _loc8_;
         _loc8_ = _loc33_ + 1;
         _loc32_ = _loc33_ * 25;
         while(_loc31_ < _loc32_)
         {
            if(_loc28_ < li8(_loc31_))
            {
               _loc9_.position = _loc31_ + 25;
               _loc9_.writeBytes(_loc9_,_loc31_,_loc32_ - _loc31_);
               break;
            }
            _loc31_ += 25;
         }
         si8(_loc28_,_loc31_);
         si32(_loc30_,_loc31_ + 1);
         si32(_loc24_ | _loc25_ | _loc26_ | _loc27_,_loc31_ + 5);
         si32(_loc15_ | _loc17_ | _loc19_ | _loc21_,_loc31_ + 9);
         si32(_loc16_ | _loc18_ | _loc20_ | _loc22_,_loc31_ + 13);
         si32(_loc7_,_loc31_ + 17);
         si32(_loc23_ - _loc7_,_loc31_ + 21);
         _loc7_ = _loc23_;
         if(li8(0) > 0)
         {
            _loc26_ = uint(-16777216);
            _loc27_ = uint(-16777216);
            while(_loc8_ < param2 && li8(_loc8_ * 25 - 25) > 1)
            {
               _loc8_--;
               _loc17_ = 16711680;
               _loc18_ = 0;
               _loc28_ = 16711680;
               _loc29_ = 0;
               _loc21_ = 255;
               _loc22_ = 0;
               _loc32_ = 255;
               _loc33_ = 0;
               _loc19_ = 65280;
               _loc20_ = 0;
               _loc30_ = 65280;
               _loc31_ = 0;
               _loc36_ = _loc8_ * 25;
               _loc34_ = uint(li32(_loc36_ + 1));
               _loc35_ = uint(li32(_loc36_ + 5) & _loc34_);
               _loc23_ = uint(li32(_loc36_ + 17));
               _loc6_ = uint(li32(_loc36_ + 21));
               _loc24_ = _loc7_;
               _loc7_ += _loc6_;
               _loc13_ = _loc24_;
               _loc14_ = _loc7_;
               _loc6_ += _loc23_;
               if(_loc7_ > 1024)
               {
                  _loc9_.length = _loc7_;
               }
               _loc11_ = uint(~li32(_loc23_));
               do
               {
                  _loc10_ = uint(li32(_loc23_));
                  _loc23_ += 4;
                  if(_loc10_ != _loc11_)
                  {
                     _loc11_ = _loc10_;
                     _loc25_ = uint(_loc10_ & _loc34_);
                     if(_loc25_ <= _loc35_)
                     {
                        _loc12_ = uint(_loc10_ & 0xFF0000);
                        if(_loc12_ < _loc17_)
                        {
                           _loc17_ = _loc12_;
                        }
                        if(_loc12_ > _loc18_)
                        {
                           _loc18_ = _loc12_;
                        }
                        _loc12_ = uint(_loc10_ & 0xFF00);
                        if(_loc12_ < _loc19_)
                        {
                           _loc19_ = _loc12_;
                        }
                        if(_loc12_ > _loc20_)
                        {
                           _loc20_ = _loc12_;
                        }
                        _loc12_ = uint(_loc10_ & 0xFF);
                        if(_loc12_ < _loc21_)
                        {
                           _loc21_ = _loc12_;
                        }
                        if(_loc12_ > _loc22_)
                        {
                           _loc22_ = _loc12_;
                        }
                        si32(_loc10_,_loc13_);
                        _loc13_ += 4;
                     }
                     else
                     {
                        _loc12_ = uint(_loc10_ & 0xFF0000);
                        if(_loc12_ < _loc28_)
                        {
                           _loc28_ = _loc12_;
                        }
                        if(_loc12_ > _loc29_)
                        {
                           _loc29_ = _loc12_;
                        }
                        _loc12_ = uint(_loc10_ & 0xFF00);
                        if(_loc12_ < _loc30_)
                        {
                           _loc30_ = _loc12_;
                        }
                        if(_loc12_ > _loc31_)
                        {
                           _loc31_ = _loc12_;
                        }
                        _loc12_ = uint(_loc10_ & 0xFF);
                        if(_loc12_ < _loc32_)
                        {
                           _loc32_ = _loc12_;
                        }
                        if(_loc12_ > _loc33_)
                        {
                           _loc33_ = _loc12_;
                        }
                        _loc14_ -= 4;
                        si32(_loc10_,_loc14_);
                     }
                  }
               }
               while(_loc23_ < _loc6_);
               _loc37_ = uint(-16777216);
               _loc38_ = 0;
               _loc39_ = 0;
               _loc40_ = 0;
               _loc41_ = 0;
               _loc42_ = 0;
               _loc43_ = 0;
               if(_loc37_ > 0)
               {
                  _loc38_ = uint(_loc18_ + _loc17_ >>> 1 & 0xFF0000);
                  _loc39_ = uint(_loc20_ + _loc19_ >>> 1 & 0xFF00);
                  _loc40_ = uint(_loc22_ + _loc21_ >>> 1 & 0xFF);
                  _loc44_ = _loc22_ - _loc21_;
                  if(_loc44_ > _loc41_)
                  {
                     _loc41_ = _loc44_;
                     _loc42_ = _loc40_;
                     _loc43_ = 255;
                  }
                  _loc44_ = uint(_loc20_ - _loc19_ >>> 8);
                  if(_loc44_ > _loc41_)
                  {
                     _loc41_ = _loc44_;
                     _loc42_ = _loc39_;
                     _loc43_ = 65280;
                  }
                  _loc44_ = uint(_loc18_ - _loc17_ >>> 16);
                  if(_loc44_ > _loc41_)
                  {
                     _loc41_ = _loc44_;
                     _loc42_ = _loc38_;
                     _loc43_ = 16711680;
                  }
               }
               _loc44_ = 0;
               _loc46_ = _loc8_;
               _loc8_ = _loc46_ + 1;
               _loc45_ = _loc46_ * 25;
               while(_loc44_ < _loc45_)
               {
                  if(_loc41_ < li8(_loc44_))
                  {
                     _loc9_.position = _loc44_ + 25;
                     _loc9_.writeBytes(_loc9_,_loc44_,_loc45_ - _loc44_);
                     break;
                  }
                  _loc44_ += 25;
               }
               si8(_loc41_,_loc44_);
               si32(_loc43_,_loc44_ + 1);
               si32(_loc37_ | _loc38_ | _loc39_ | _loc40_,_loc44_ + 5);
               si32(_loc15_ | _loc17_ | _loc19_ | _loc21_,_loc44_ + 9);
               si32(_loc16_ | _loc18_ | _loc20_ | _loc22_,_loc44_ + 13);
               si32(_loc24_,_loc44_ + 17);
               si32(_loc13_ - _loc24_,_loc44_ + 21);
               _loc37_ = uint(-16777216);
               _loc38_ = 0;
               _loc39_ = 0;
               _loc40_ = 0;
               _loc41_ = 0;
               _loc42_ = 0;
               _loc43_ = 0;
               if(_loc37_ > 0)
               {
                  _loc38_ = uint(_loc29_ + _loc28_ >>> 1 & 0xFF0000);
                  _loc39_ = uint(_loc31_ + _loc30_ >>> 1 & 0xFF00);
                  _loc40_ = uint(_loc33_ + _loc32_ >>> 1 & 0xFF);
                  _loc44_ = _loc33_ - _loc32_;
                  if(_loc44_ > _loc41_)
                  {
                     _loc41_ = _loc44_;
                     _loc42_ = _loc40_;
                     _loc43_ = 255;
                  }
                  _loc44_ = uint(_loc31_ - _loc30_ >>> 8);
                  if(_loc44_ > _loc41_)
                  {
                     _loc41_ = _loc44_;
                     _loc42_ = _loc39_;
                     _loc43_ = 65280;
                  }
                  _loc44_ = uint(_loc29_ - _loc28_ >>> 16);
                  if(_loc44_ > _loc41_)
                  {
                     _loc41_ = _loc44_;
                     _loc42_ = _loc38_;
                     _loc43_ = 16711680;
                  }
               }
               _loc44_ = 0;
               _loc46_ = _loc8_;
               _loc8_ = _loc46_ + 1;
               _loc45_ = _loc46_ * 25;
               while(_loc44_ < _loc45_)
               {
                  if(_loc41_ < li8(_loc44_))
                  {
                     _loc9_.position = _loc44_ + 25;
                     _loc9_.writeBytes(_loc9_,_loc44_,_loc45_ - _loc44_);
                     break;
                  }
                  _loc44_ += 25;
               }
               si8(_loc41_,_loc44_);
               si32(_loc43_,_loc44_ + 1);
               si32(_loc37_ | _loc38_ | _loc39_ | _loc40_,_loc44_ + 5);
               si32(_loc26_ | _loc28_ | _loc30_ | _loc32_,_loc44_ + 9);
               si32(_loc27_ | _loc29_ | _loc31_ | _loc33_,_loc44_ + 13);
               si32(_loc14_,_loc44_ + 17);
               si32(_loc7_ - _loc14_,_loc44_ + 21);
            }
         }
         _loc14_ = 0;
         _loc47_ = [];
         _loc48_ = new Vector.<uint>();
         _loc6_ = _loc8_ * 25;
         _loc23_ = 0;
         do
         {
            _loc12_ = _loc23_ * 25;
            _loc48_.push(li32(_loc12_ + 5));
            _loc13_ = uint(li32(_loc12_ + 17));
            _loc7_ = li32(_loc12_ + 21) + _loc13_;
            do
            {
               _loc14_++;
               _loc47_[li32(_loc13_) >>> 0] = _loc23_;
            }
            while(_loc13_ += 4, _loc13_ < _loc7_);
         }
         while(++_loc23_ < _loc8_);
         ApplicationDomain.currentDomain.domainMemory = _loc3_;
         return [_loc48_,_loc47_];
      }
   }
}

