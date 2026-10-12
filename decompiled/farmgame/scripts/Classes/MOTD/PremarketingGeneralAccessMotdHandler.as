package Classes.MOTD
{
   import Managers.XBOPremarketingManager;
   
   public class PremarketingGeneralAccessMotdHandler extends ExpansionAccessMotdHandler
   {
      
      public function PremarketingGeneralAccessMotdHandler(currentMOTD:Object, addPopupToQueue:Boolean = true)
      {
         super(currentMOTD,addPopupToQueue);
      }
      
      override protected function get assetPath() : String
      {
         return m_currentMOTD.customWindowParams.dialog;
      }
      
      override protected function get onBoardingWindowClass() : String
      {
         return m_currentMOTD.windowType;
      }
      
      override public function execute() : void
      {
         var premarketingManager:XBOPremarketingManager = XBOPremarketingManager.instance(m_currentMOTD.customActionParams.featureName);
         if(Boolean(premarketingManager) && Boolean(premarketingManager.isActive) && premarketingManager.hasRewards)
         {
            super.execute();
         }
      }
   }
}

