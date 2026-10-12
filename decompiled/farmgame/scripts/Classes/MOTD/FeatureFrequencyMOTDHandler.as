package Classes.MOTD
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.TransactionManager;
   import Transactions.TSawMOTD;
   import flash.events.Event;
   
   public class FeatureFrequencyMOTDHandler extends MOTDHandler
   {
      
      private var m_featureFrequencyKey:String = null;
      
      public function FeatureFrequencyMOTDHandler(currentMOTD:Object)
      {
         var prereq:Object = null;
         super(currentMOTD);
         if(currentMOTD.hasOwnProperty(PrerequisiteConstants.PREREQS_XML_TAG) && currentMOTD[PrerequisiteConstants.PREREQS_XML_TAG] != null)
         {
            for each(prereq in currentMOTD[PrerequisiteConstants.PREREQS_XML_TAG])
            {
               if(prereq.hasOwnProperty(PrerequisiteConstants.KEY_TYPE) && prereq[PrerequisiteConstants.KEY_TYPE] != null && prereq[PrerequisiteConstants.KEY_TYPE] == PrerequisiteConstants.PREREQUISITE_FEATURE_FREQUENCY && prereq.hasOwnProperty(PrerequisiteConstants.KEY_VALUE) && prereq[PrerequisiteConstants.KEY_VALUE] != null)
               {
                  this.m_featureFrequencyKey = prereq[PrerequisiteConstants.KEY_VALUE];
                  break;
               }
            }
         }
      }
      
      override protected function acceptMOTD() : void
      {
         if(!Global.flashHotParams["MP_MOTD_CLICK_TEMPRT"])
         {
            ztrack("click");
         }
         this.closeMOTD();
      }
      
      override protected function closeMOTD() : void
      {
         this.setFeatureFrequency();
         dispatchEvent(new Event(Event.COMPLETE));
         removeAllEventListeners();
      }
      
      private function setFeatureFrequency() : void
      {
         if(this.m_featureFrequencyKey != null)
         {
            Global.player.setFeatureLastShown(this.m_featureFrequencyKey,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         }
         else
         {
            TransactionManager.addTransaction(new TSawMOTD(m_currentMOTD),true);
         }
      }
   }
}

