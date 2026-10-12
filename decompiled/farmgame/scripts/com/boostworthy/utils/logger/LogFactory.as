package com.boostworthy.utils.logger
{
   import com.boostworthy.collections.HashMap;
   import com.boostworthy.collections.iterators.IIterator;
   import com.boostworthy.core.IDisposable;
   
   public class LogFactory implements IDisposable
   {
      
      private static var c_objInstance:LogFactory;
      
      private var m_objLogHash:HashMap;
      
      private var m_uLevel:uint;
      
      public function LogFactory(param1:SingletonEnforcer)
      {
         super();
         this.init();
      }
      
      public static function getInstance() : LogFactory
      {
         if(c_objInstance == null)
         {
            c_objInstance = new LogFactory(new SingletonEnforcer());
         }
         return c_objInstance;
      }
      
      public function getLevel() : uint
      {
         return this.m_uLevel;
      }
      
      public function setLevel(param1:uint) : void
      {
         this.m_uLevel = param1;
         var _loc2_:IIterator = this.m_objLogHash.getValueIterator();
         while(_loc2_.hasNext())
         {
            _loc2_.next().setLevel(this.m_uLevel);
         }
      }
      
      public function getLog(param1:String) : ILog
      {
         if(this.m_objLogHash.containsKey(param1))
         {
            return this.m_objLogHash.get(param1) as ILog;
         }
         this.m_objLogHash.put(param1,new Log(param1,this.m_uLevel));
         return this.m_objLogHash.get(param1) as ILog;
      }
      
      public function dispose() : void
      {
         this.m_objLogHash.dispose();
      }
      
      protected function init() : void
      {
         this.m_uLevel = LogSettings.DEFAULT_LOG_LEVEL;
         this.m_objLogHash = new HashMap();
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
