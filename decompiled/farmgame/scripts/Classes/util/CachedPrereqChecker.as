package Classes.util
{
   import Classes.Quest.PrerequisiteUtility;
   
   public class CachedPrereqChecker
   {
      
      protected var m_cachedResult:Boolean;
      
      protected var m_prereqData:Array;
      
      protected var m_context:Object;
      
      protected var m_initialized:Boolean;
      
      public function CachedPrereqChecker(prereqData:Array, context:Object = null)
      {
         super();
         this.m_prereqData = prereqData;
         this.m_context = context;
         this.m_initialized = false;
      }
      
      public function passesPrereqs(refresh:Boolean = false) : Boolean
      {
         var result:Boolean = false;
         var foundFailedPrereq:Boolean = false;
         var prereq:Object = null;
         if(refresh || !this.m_initialized)
         {
            this.m_initialized = true;
            this.m_cachedResult = false;
            if(!this.m_prereqData)
            {
               this.m_cachedResult = true;
            }
            else
            {
               foundFailedPrereq = false;
               for each(prereq in this.m_prereqData)
               {
                  if(!PrerequisiteUtility.isPrerequisiteMet(prereq,this.m_context))
                  {
                     foundFailedPrereq = true;
                     break;
                  }
               }
               this.m_cachedResult = !foundFailedPrereq;
            }
         }
         return this.m_cachedResult;
      }
   }
}

