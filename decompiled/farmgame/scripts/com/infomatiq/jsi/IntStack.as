package com.infomatiq.jsi
{
   import flash.errors.IllegalOperationError;
   
   public class IntStack
   {
      
      private static const HEAD_EMPTY:int = -1;
      
      private static const DEFAULT_SIZE:int = 10;
      
      private var m_stack:Vector.<int>;
      
      private var m_head:int;
      
      public function IntStack()
      {
         super();
         this.m_stack = new Vector.<int>(DEFAULT_SIZE);
         this.m_head = HEAD_EMPTY;
      }
      
      public function push(param1:int) : void
      {
         this.m_stack[++this.m_head] = param1;
      }
      
      public function peek() : int
      {
         if(this.m_head == HEAD_EMPTY)
         {
            throw new IllegalOperationError("Cannot peak an empty stack.");
         }
         return this.m_stack[this.m_head];
      }
      
      public function pop() : int
      {
         if(this.m_head == HEAD_EMPTY)
         {
            throw new IllegalOperationError("Cannot pop an item off of an empty stack.");
         }
         return this.m_stack[this.m_head--];
      }
      
      public function reset() : void
      {
         while(this.m_head > HEAD_EMPTY)
         {
            this.m_stack[this.m_head--] = 0;
         }
      }
      
      public function resetQuickly() : void
      {
         this.m_head = HEAD_EMPTY;
      }
      
      public function size() : int
      {
         return this.m_head + 1;
      }
   }
}

