package Widgets.Core.Util
{
   import flash.utils.getQualifiedClassName;
   
   public class ZwProfiler
   {
      
      private static var m_instance:ZwProfiler;
      
      private static var m_allowInstantiation:Boolean;
      
      protected var track:Boolean = false;
      
      protected var refCounters:Object = null;
      
      public function ZwProfiler()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use ZwProfiler.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : ZwProfiler
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new ZwProfiler();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      public function addRef(obj:*) : void
      {
         var className:String = null;
         if(this.track)
         {
            className = getQualifiedClassName(obj);
            if(this.refCounters.hasOwnProperty(className))
            {
               ++this.refCounters[className];
            }
            else
            {
               this.refCounters[className] = 1;
            }
         }
      }
      
      public function removeRef(obj:*) : void
      {
         var className:String = null;
         if(this.track)
         {
            className = getQualifiedClassName(obj);
            if(this.refCounters.hasOwnProperty(className))
            {
               --this.refCounters[className];
            }
            else
            {
               this.refCounters[className] = -1;
            }
         }
      }
      
      public function startProfile(clearRefCounters:Boolean = true) : void
      {
         this.track = true;
         if(null == this.refCounters || clearRefCounters)
         {
            this.refCounters = new Object();
         }
      }
      
      public function stopProfile() : void
      {
         this.track = false;
      }
      
      public function getProfileSummary() : String
      {
         var totalCurrentRef:int = 0;
         var key:String = null;
         var refCount:int = 0;
         var summary:String = "";
         if(this.track)
         {
            totalCurrentRef = 0;
            for(key in this.refCounters)
            {
               refCount = int(this.refCounters[key]);
               totalCurrentRef += refCount;
               summary += key + " - " + refCount.toString() + "\n";
            }
            summary = "ZWidgets Profiler Summary:\nTotal Current Ref - " + totalCurrentRef.toString() + "\n" + summary;
         }
         return summary;
      }
      
      public function traceProfileSummary() : void
      {
         if(this.track)
         {
         }
      }
   }
}

