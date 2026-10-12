package Classes.MOTD
{
   public class PremarketingEarlyAccessMotdHandler extends ExpansionEarlyAccessMotdHandler
   {
      
      public function PremarketingEarlyAccessMotdHandler(currentMOTD:Object, addPopupToQueue:Boolean = true)
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
   }
}

