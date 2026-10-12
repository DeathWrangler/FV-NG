package Events
{
   import flash.events.Event;
   
   public class FeatureMessageEvent extends Event
   {
      
      public static const FEATUREUPDATE:String = "featureUpdate";
      
      public static const FEATURE_STATE_CHANGE:String = "featureChanged";
      
      public static const MESSAGES_CALLTOACTION:String = "callToAction";
      
      private var m_featureName:String;
      
      private var m_messages:Object;
      
      public function FeatureMessageEvent(type:String, featureName:String = "", messages:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_messages = messages;
         super(type,bubbles,cancelable);
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function get callToActionMessage() : String
      {
         return this.m_messages[MESSAGES_CALLTOACTION];
      }
      
      public function hasCallToActionMessage() : Boolean
      {
         return this.m_messages.hasOwnProperty(MESSAGES_CALLTOACTION);
      }
   }
}

