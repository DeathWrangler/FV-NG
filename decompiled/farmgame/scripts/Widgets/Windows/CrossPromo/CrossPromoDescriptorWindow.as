package Widgets.Windows.CrossPromo
{
   import Classes.CrossPromoDescriptor;
   import Classes.CrossPromoDescriptorManager;
   
   public class CrossPromoDescriptorWindow extends CrossPromoWindow
   {
      
      protected var m_crossPromoDescriptor:CrossPromoDescriptor;
      
      public function CrossPromoDescriptorWindow(crossPromoDescriptor:CrossPromoDescriptor)
      {
         this.m_crossPromoDescriptor = crossPromoDescriptor;
         super(crossPromoDescriptor.dialogAsset,crossPromoDescriptor.promoName,crossPromoDescriptor.gameID,crossPromoDescriptor.showCheckboxToRemoveItem,null,crossPromoDescriptor.billboardItemName);
      }
      
      override protected function getAcceptButtonText() : String
      {
         var acceptButtonText:String = super.getAcceptButtonText();
         var acceptButtonTextTmp:String = this.m_crossPromoDescriptor.dialogAcceptText;
         if(acceptButtonTextTmp != null && acceptButtonTextTmp != "")
         {
            acceptButtonText = acceptButtonTextTmp;
         }
         return acceptButtonText;
      }
      
      override protected function getDialogBodyText() : String
      {
         var dialogBodyText:String = super.getDialogBodyText();
         var dialogBodyTextTmp:String = this.m_crossPromoDescriptor.dialogBodyText;
         if(dialogBodyTextTmp != null && dialogBodyTextTmp != "")
         {
            dialogBodyText = dialogBodyTextTmp;
         }
         return dialogBodyText;
      }
      
      override protected function getPlayUrl() : String
      {
         var playUrl:String = super.getPlayUrl();
         var playUrlTmp:String = this.m_crossPromoDescriptor.playUrl;
         if(playUrlTmp != null && playUrlTmp != "")
         {
            playUrl = playUrlTmp;
         }
         return playUrl;
      }
      
      override protected function setBillboardRemoveSeenFlag() : void
      {
         CrossPromoDescriptorManager.setRemoveBillboardSeenFlag(this.m_crossPromoDescriptor);
      }
   }
}

