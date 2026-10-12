package zasp.Display
{
   import flash.display.Sprite;
   import flash.events.Event;
   import zasp.Util.CircularBuffer;
   import zasp.Util.Sampler;
   
   public class FunkySpinner extends Sprite implements Sampler
   {
      
      private static const PHI:Number = (1 + Math.sqrt(5)) / 2;
      
      private static const goldenSpiralC:Number = 1 / Math.pow(PHI,4);
      
      private static const silverSpiralC:Number = 1 / Math.pow(PHI,2);
      
      private static const copperSpiralC:Number = 1 / PHI;
      
      private static const C:Number = silverSpiralC;
      
      private static const millisPerCycle:Number = 2000;
      
      private static const slicesPerCycle:int = 60;
      
      private static const totalNumSlices:int = 2.5 * slicesPerCycle;
      
      private static const colors:Array = [0,16711680,65280,255,8355711,16744319,8388479,8355839,12566463,16760767,12582847,12566527,14671839,16768991,14680031,14671871,16777215];
      
      private var slices:Array;
      
      private var samplesMillis:CircularBuffer = null;
      
      public function FunkySpinner(param1:Number, param2:Number, param3:Number)
      {
         var _loc5_:ColorPoly = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         this.slices = new Array();
         super();
         this.samplesMillis = new CircularBuffer(colors.length - 1);
         var _loc4_:int = 0;
         while(_loc4_ < totalNumSlices)
         {
            _loc5_ = new ColorPoly();
            this.slices.push(_loc5_);
            addChild(_loc5_);
            _loc6_ = Math.PI;
            _loc7_ = 2 * _loc6_ * (_loc4_ + 0) / slicesPerCycle - _loc6_ / 2;
            _loc8_ = 2 * _loc6_ * (_loc4_ + 1) / slicesPerCycle - _loc6_ / 2;
            _loc9_ = Math.cos(_loc7_);
            _loc10_ = Math.sin(_loc7_);
            _loc11_ = Math.cos(_loc8_);
            _loc12_ = Math.sin(_loc8_);
            _loc13_ = param3 * Math.pow(C,(_loc4_ + 0) / slicesPerCycle);
            _loc14_ = _loc13_ * C;
            _loc15_ = param3 * Math.pow(C,(_loc4_ + 1) / slicesPerCycle);
            _loc16_ = _loc15_ * C;
            _loc17_ = param1 + _loc13_ * _loc9_;
            _loc18_ = param2 + _loc13_ * _loc10_;
            _loc19_ = param1 + _loc14_ * _loc9_;
            _loc20_ = param2 + _loc14_ * _loc10_;
            _loc21_ = param1 + _loc15_ * _loc11_;
            _loc22_ = param2 + _loc15_ * _loc12_;
            _loc23_ = param1 + _loc16_ * _loc11_;
            _loc24_ = param2 + _loc16_ * _loc12_;
            _loc5_.addPt(_loc17_,_loc18_);
            _loc5_.addPt(_loc21_,_loc22_);
            _loc5_.addPt(_loc23_,_loc24_);
            _loc5_.addPt(_loc19_,_loc20_);
            _loc5_.addPt(_loc17_,_loc18_);
            _loc4_++;
         }
         this.addListener(Event.ADDED_TO_STAGE,this.added_to_stage);
      }
      
      public function sample(param1:Number) : void
      {
         while(this.samplesMillis.length >= this.samplesMillis.capacity - 1)
         {
            this.samplesMillis.pop();
         }
         this.samplesMillis.push(param1);
      }
      
      private function addListener(param1:String, param2:Function) : void
      {
         addEventListener(param1,param2,false,0,true);
      }
      
      private function removeListener(param1:String, param2:Function) : void
      {
         removeEventListener(param1,param2,false);
      }
      
      private function added_to_stage(param1:Event) : void
      {
         this.removeListener(Event.ADDED_TO_STAGE,this.added_to_stage);
         this.addListener(Event.ENTER_FRAME,this.enter_frame);
         this.addListener(Event.REMOVED_FROM_STAGE,this.removed_from_stage);
      }
      
      private function removed_from_stage(param1:Event) : void
      {
         this.addListener(Event.ADDED_TO_STAGE,this.added_to_stage);
         this.removeListener(Event.ENTER_FRAME,this.enter_frame);
         this.removeListener(Event.REMOVED_FROM_STAGE,this.removed_from_stage);
      }
      
      private function enter_frame(param1:Event) : void
      {
         var _loc8_:ColorPoly = null;
         var _loc2_:Number = millisPerCycle / slicesPerCycle;
         var _loc3_:int = Math.min(colors.length,this.samplesMillis.length);
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = 0;
         var _loc7_:int = 0;
         if(this.samplesMillis.length > 0)
         {
            _loc7_ = this.samplesMillis.length - 1;
            _loc6_ = this.samplesMillis.elementAt(_loc7_) as Number;
         }
         while(_loc5_ < _loc3_ && _loc4_ < totalNumSlices)
         {
            _loc8_ = this.slices[_loc4_] as ColorPoly;
            _loc8_.changeColor(colors[_loc5_]);
            _loc4_++;
            while(_loc2_ * _loc4_ > _loc6_ && _loc5_ < _loc3_)
            {
               _loc7_ = this.samplesMillis.length - _loc5_ - 1;
               _loc6_ += this.samplesMillis.elementAt(_loc7_) as Number;
               _loc5_++;
            }
         }
         while(_loc4_ < totalNumSlices)
         {
            _loc8_ = this.slices[_loc4_] as ColorPoly;
            _loc8_.changeColor(colors[colors.length - 1]);
            _loc4_++;
         }
      }
   }
}

