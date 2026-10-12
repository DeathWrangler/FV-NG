package Classes
{
   public class SmartSystemData
   {
      
      public static const KEY_SMART_SYSTEM_MULTIPLIER:String = "multiplier";
      
      public static const KEY_SMART_SYSTEM_ACTUAL_BUCKET:String = "actualBucket";
      
      public static const KEY_SMART_SYSTEM_ASSIGNED_BUCKET:String = "assignedBucket";
      
      private var m_multiplier:Number = 0;
      
      private var m_actualBucket:String = "";
      
      private var m_assignedBucket:String = "";
      
      public function SmartSystemData(config:Object)
      {
         super();
         if(config.hasOwnProperty(KEY_SMART_SYSTEM_MULTIPLIER))
         {
            this.m_multiplier = config[KEY_SMART_SYSTEM_MULTIPLIER];
         }
         if(config.hasOwnProperty(KEY_SMART_SYSTEM_ACTUAL_BUCKET))
         {
            this.m_actualBucket = config[KEY_SMART_SYSTEM_ACTUAL_BUCKET];
         }
         if(config.hasOwnProperty(KEY_SMART_SYSTEM_ASSIGNED_BUCKET))
         {
            this.m_assignedBucket = config[KEY_SMART_SYSTEM_ASSIGNED_BUCKET];
         }
      }
      
      public function get multiplier() : Number
      {
         return this.m_multiplier;
      }
      
      public function get actualBucket() : String
      {
         return this.m_actualBucket;
      }
      
      public function get assignedBucket() : String
      {
         return this.m_assignedBucket;
      }
   }
}

