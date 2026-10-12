package com.boostworthy.collections
{
   import com.boostworthy.collections.iterators.ForwardArrayIterator;
   import com.boostworthy.collections.iterators.IIterator;
   import com.boostworthy.collections.iterators.IteratorType;
   import com.boostworthy.collections.iterators.ReverseArrayIterator;
   import com.boostworthy.core.Global;
   import com.boostworthy.core.IDisposable;
   
   public class HashMap implements ICollection, IDisposable
   {
      
      protected var m_aKeys:Array;
      
      protected var m_aValues:Array;
      
      public function HashMap(param1:Object = null)
      {
         super();
         this.init(param1);
      }
      
      public function clone() : HashMap
      {
         var _loc1_:HashMap = new HashMap();
         var _loc2_:int = int(this.m_aKeys.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_.put(this.m_aKeys[_loc3_],this.m_aValues[_loc3_]);
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function put(param1:Object, param2:Object) : void
      {
         this.remove(param1);
         this.m_aKeys.push(param1);
         this.m_aValues.push(param2);
      }
      
      public function putMap(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            this.put(_loc2_,param1[_loc2_]);
         }
      }
      
      public function get(param1:Object) : Object
      {
         var _loc2_:int = this.searchForKey(param1);
         if(_loc2_ != com.boostworthy.core.Global.NULL_INDEX)
         {
            return this.m_aValues[_loc2_];
         }
         return null;
      }
      
      public function remove(param1:Object) : void
      {
         var _loc2_:int = this.searchForKey(param1);
         if(_loc2_ != com.boostworthy.core.Global.NULL_INDEX)
         {
            this.m_aKeys.splice(_loc2_,1);
            this.m_aValues.splice(_loc2_,1);
         }
      }
      
      public function containsKey(param1:Object) : Boolean
      {
         return this.searchForKey(param1) != com.boostworthy.core.Global.NULL_INDEX;
      }
      
      public function get length() : uint
      {
         return this.m_aKeys.length;
      }
      
      public function getIterator(param1:uint = 2) : IIterator
      {
         return this.getValueIterator(param1);
      }
      
      public function getKeyIterator(param1:uint = 2) : IIterator
      {
         if(param1 == IteratorType.ARRAY_FORWARD)
         {
            return new ForwardArrayIterator(this.m_aKeys.concat());
         }
         if(param1 == IteratorType.ARRAY_REVERSE)
         {
            return new ReverseArrayIterator(this.m_aKeys.concat());
         }
         return new ForwardArrayIterator(this.m_aKeys.concat());
      }
      
      public function getValueIterator(param1:uint = 2) : IIterator
      {
         if(param1 == IteratorType.ARRAY_FORWARD)
         {
            return new ForwardArrayIterator(this.m_aValues.concat());
         }
         if(param1 == IteratorType.ARRAY_REVERSE)
         {
            return new ReverseArrayIterator(this.m_aValues.concat());
         }
         return new ForwardArrayIterator(this.m_aValues.concat());
      }
      
      public function dispose() : void
      {
         this.m_aKeys = new Array();
         this.m_aValues = new Array();
      }
      
      protected function init(param1:Object) : void
      {
         this.dispose();
         if(param1 != null)
         {
            this.putMap(param1);
         }
      }
      
      protected function searchForKey(param1:Object) : int
      {
         var _loc2_:int = int(this.m_aKeys.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.m_aKeys[_loc3_] === param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return com.boostworthy.core.Global.NULL_INDEX;
      }
   }
}

