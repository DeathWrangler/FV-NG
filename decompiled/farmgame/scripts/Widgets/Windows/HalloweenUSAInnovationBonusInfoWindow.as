package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class HalloweenUSAInnovationBonusInfoWindow extends FarmWindow
   {
      
      private var m_featureName:String = null;
      
      public function HalloweenUSAInnovationBonusInfoWindow(featureName:String, windowUrl:String)
      {
         this.m_featureName = featureName;
         super(windowUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         m_window.visible = true;
         if(Boolean(m_window) && Boolean(m_window.mainWindow))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_BonusInfoWindowTitle")));
            }
            if(m_window.mainWindow.description_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.description_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_BonusInfoWindowBody")));
            }
            if(m_window.mainWindow.generic_bt)
            {
               m_closeButton = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_bt,"Awesome!",this.onCloseButtonClick)) as FarmAnimatedTextButton;
            }
         }
      }
      
      private function onCloseButtonClick(e:Event) : void
      {
         close();
         HalloweenInnovationManager.getInstance().mainWindow.untintWindow();
         HalloweenInnovationManager.getInstance().mainWindow.enableInput = true;
      }
   }
}

