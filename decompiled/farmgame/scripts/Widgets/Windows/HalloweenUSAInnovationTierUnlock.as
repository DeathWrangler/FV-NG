package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class HalloweenUSAInnovationTierUnlock extends FarmWindow
   {
      
      protected var m_featureName:String = null;
      
      protected var title_tf:ZwTextField = null;
      
      private var m_unlockedTabName:String;
      
      public function HalloweenUSAInnovationTierUnlock(dialogAsset:String, featureName:String, unlockedTabName:String)
      {
         super(dialogAsset);
         this.m_featureName = featureName;
         this.m_unlockedTabName = unlockedTabName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["title_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tierUnlockTitle"))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic_tf"))
            {
               addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tierUnlockSubTitle",{"tierName":this.m_unlockedTabName})));
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tierUnlockSubText")));
            }
            if(m_window.hasOwnProperty("okay_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Continue",this.onCloseWindow));
            }
         }
      }
      
      public function onCloseWindow(event:Event) : void
      {
         HalloweenInnovationManager.getInstance().mainWindow.untintWindow();
         HalloweenInnovationManager.getInstance().mainWindow.enableInput = true;
         this.close();
      }
   }
}

