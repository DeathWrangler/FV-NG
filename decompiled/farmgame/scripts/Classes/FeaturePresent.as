package Classes
{
   public class FeaturePresent
   {
      
      public static const PRESENT_UNOPENED:Number = 0;
      
      private var m_featureName:String = "";
      
      private var m_fullFriendId:String = "";
      
      private var m_friendId:String = "";
      
      private var m_creationTimestamp:Number = 0;
      
      private var m_presentItemCode:String = "";
      
      private var m_openTimestamp:Number = 0;
      
      public function FeaturePresent(featureName:String, fullFriendId:String, friendId:String, creationTimestamp:Number, presentItemCode:String, openTimestamp:Number)
      {
         super();
         this.m_featureName = featureName;
         this.m_fullFriendId = fullFriendId;
         this.m_friendId = friendId;
         this.m_creationTimestamp = creationTimestamp;
         this.m_presentItemCode = presentItemCode;
         this.m_openTimestamp = openTimestamp;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function set featureName(value:String) : void
      {
         this.m_featureName = value;
      }
      
      public function get fullFriendId() : String
      {
         return this.m_fullFriendId;
      }
      
      public function set fullFriendId(value:String) : void
      {
         this.m_fullFriendId = value;
      }
      
      public function get friendId() : String
      {
         return this.m_friendId;
      }
      
      public function set friendId(value:String) : void
      {
         this.m_friendId = value;
      }
      
      public function get creationTimestamp() : Number
      {
         return this.m_creationTimestamp;
      }
      
      public function set creationTimestamp(value:Number) : void
      {
         this.m_creationTimestamp = value;
      }
      
      public function get presentItemCode() : String
      {
         return this.m_presentItemCode;
      }
      
      public function set presentItemCode(value:String) : void
      {
         this.m_presentItemCode = value;
      }
      
      public function get openTimestamp() : Number
      {
         return this.m_openTimestamp;
      }
      
      public function set openTimestamp(value:Number) : void
      {
         this.m_openTimestamp = value;
      }
   }
}

