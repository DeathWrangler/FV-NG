package com.boostworthy.animation.sequence
{
   import com.boostworthy.animation.sequence.tweens.ITween;
   import com.boostworthy.collections.Stack;
   import com.boostworthy.collections.iterators.IIterator;
   
   public class TweenStack extends Stack
   {
      
      public function TweenStack()
      {
         super();
      }
      
      override public function addElement(param1:Object) : void
      {
         var _loc7_:ITween = null;
         var _loc2_:ITween = param1 as ITween;
         var _loc3_:Array = new Array();
         var _loc4_:IIterator = getIterator();
         while(_loc4_.hasNext())
         {
            _loc7_ = _loc4_.next() as ITween;
            if(_loc7_.target == _loc2_.target && _loc7_.property == _loc2_.property)
            {
               if(_loc7_.firstFrame > _loc2_.firstFrame)
               {
                  _loc3_.push(_loc7_.clone());
                  removeElement(_loc7_);
               }
            }
         }
         super.addElement(_loc2_);
         var _loc5_:int = int(_loc3_.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            super.addElement(_loc3_[_loc6_]);
            _loc6_++;
         }
      }
   }
}

