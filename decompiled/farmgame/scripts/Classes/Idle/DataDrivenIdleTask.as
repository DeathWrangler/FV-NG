package Classes.Idle
{
   import Classes.Quest.PrerequisiteUtility;
   import Engine.Managers.ErrorManager;
   import flash.utils.getDefinitionByName;
   
   public class DataDrivenIdleTask extends BaseIdleTask
   {
      
      private var m_name:String;
      
      private var m_delegateClassName:String;
      
      private var m_delegateMethod:String;
      
      private var m_idleDelayMS:int;
      
      private var m_prereqs:Array = [];
      
      private var m_params:XML;
      
      public function DataDrivenIdleTask(name:String, delegateClassName:String, delegateMethod:String, prereqs:Array, idleDelayMS:int, params:XML = null)
      {
         super();
         this.m_delegateClassName = delegateClassName;
         this.m_delegateMethod = delegateMethod;
         this.m_idleDelayMS = idleDelayMS;
         this.m_prereqs = prereqs;
         this.m_name = name;
         this.m_params = params;
      }
      
      public static function createFromXML(idleTaskXML:XML) : DataDrivenIdleTask
      {
         var prereqs:Array = null;
         var delayMS:int = 0;
         var actionTarget:String = idleTaskXML.action.@target;
         var actionMethod:String = idleTaskXML.action.@method;
         var task:DataDrivenIdleTask = null;
         var name:String = idleTaskXML.@name;
         var params:XML = null;
         if(idleTaskXML.hasOwnProperty("params"))
         {
            params = idleTaskXML.params[0];
         }
         if(Boolean(actionTarget) && Boolean(actionMethod))
         {
            prereqs = PrerequisiteUtility.parseXmlNodePrereqs(idleTaskXML.prereqs.children());
            delayMS = idleTaskXML.hasOwnProperty("@delayMS") ? int(parseInt(idleTaskXML.@delayMS)) : int(BaseIdleTask.DEFAULT_MOUSE_MILLISECONDS);
            task = new DataDrivenIdleTask(name,actionTarget,actionMethod,prereqs,delayMS,params);
         }
         else
         {
            ErrorManager.addError("DataDrivenIdleTask error creating task from xml:" + idleTaskXML.toXMLString());
         }
         return task;
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return this.m_idleDelayMS;
      }
      
      override public function get queueCoolDownMilliseconds() : Number
      {
         return this.m_idleDelayMS;
      }
      
      private function arePrerequisitesMet() : Boolean
      {
         var result:Boolean = true;
         if(Boolean(this.m_prereqs) && Boolean(this.m_prereqs.length))
         {
            result = PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
         }
         return result;
      }
      
      override public function get canFire() : Boolean
      {
         return this.arePrerequisitesMet();
      }
      
      override public function get shouldAdd() : Boolean
      {
         return this.arePrerequisitesMet();
      }
      
      override public function get canHaveDuplicates() : Boolean
      {
         return true;
      }
      
      override public function fire() : void
      {
         var instClass:Object = null;
         var myclass:Class = getDefinitionByName(this.m_delegateClassName) as Class;
         if(myclass != null && (myclass as Object).hasOwnProperty(this.m_delegateMethod))
         {
            if(!this.m_params)
            {
               myclass[this.m_delegateMethod]();
            }
            else
            {
               myclass[this.m_delegateMethod](this.m_params);
            }
         }
         else
         {
            instClass = new myclass();
            if(this.m_delegateMethod in instClass)
            {
               instClass[this.m_delegateMethod]();
            }
            else
            {
               ErrorManager.addError("DataDrivenIdleTask error executing target:" + this.m_delegateClassName + " method:" + this.m_delegateMethod);
            }
         }
      }
   }
}

