package Widgets.Frames
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class OrganicRewardBadgeFrame extends ZwFrame
   {
      
      private static const ONE_CERTIFIED_TEXT:String = "OrganicCertification_OneCertifiedText";
      
      private static const CERTIFIED_TEXT:String = "OrganicCertification_CertifiedText";
      
      public function OrganicRewardBadgeFrame(element:DisplayObject, numberCertified:int)
      {
         super(element);
         this.setUpSlot(numberCertified);
      }
      
      protected function setUpSlot(numCertfiedCrops:int) : void
      {
         var certifiedTextKey:String = null;
         if(m_element.number_tf)
         {
            addWidget(new ZwTextField(m_element.number_tf,numCertfiedCrops.toString()),true);
         }
         if(m_element.generic_tf)
         {
            if(numCertfiedCrops == 1)
            {
               certifiedTextKey = ONE_CERTIFIED_TEXT;
            }
            else
            {
               certifiedTextKey = CERTIFIED_TEXT;
            }
            addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,certifiedTextKey)),true);
         }
      }
   }
}

