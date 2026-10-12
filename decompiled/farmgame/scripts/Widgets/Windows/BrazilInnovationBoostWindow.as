package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.OrderBoard.DreamWorldInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class BrazilInnovationBoostWindow extends FarmWindow
   {
      
      private var m_marketItems:Array = new Array();
      
      private var m_featureName:String = null;
      
      private var m_subFeatureName:String = null;
      
      private var m_callback:Function = null;
      
      private var m_textPrefix:String = this.m_subFeatureName ? this.m_featureName + "_" + this.m_subFeatureName : this.m_featureName;
      
      private var m_ownerWindow:DreamWorldInnovationWindow;
      
      public function BrazilInnovationBoostWindow(dialogAsset:String, featureName:String = null, subFeatureName:String = null, callBack:Function = null, owner:DreamWorldInnovationWindow = null)
      {
         this.m_featureName = featureName;
         this.m_ownerWindow = owner;
         this.m_callback = callBack;
         this.m_subFeatureName = subFeatureName;
         this.m_marketItems.push(DreamWorldInnovationManager.ALASKA_TILE_LIST);
         super(dialogAsset);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.mainWindow))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow.title_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_title")));
            }
            if(m_window.mainWindow.body_tf)
            {
               addWidget(new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_textPrefix + "_desc")));
            }
            if(m_window.mainWindow.close_bt)
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onCloseButtonClick)) as FarmButton;
            }
            if(m_window.mainWindow.generic_bt)
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_bt,"Unlock Tiles",this.onUnlockButtonClick));
            }
         }
      }
      
      private function onUnlockButtonClick(event:MouseEvent) : void
      {
         StatsManager.count(this.m_featureName,"BoostUI","unlock");
         if(this.m_ownerWindow)
         {
            this.m_ownerWindow.untintWindow();
            this.m_ownerWindow.enableInput = true;
            this.m_ownerWindow.close();
         }
         close();
         UI.displayMiniMarketDialog(this.m_marketItems[0],null,"seed",null,true,false,false,true);
      }
      
      private function onCloseButtonClick(event:MouseEvent) : void
      {
         if(this.m_ownerWindow)
         {
            this.m_ownerWindow.untintWindow();
            this.m_ownerWindow.enableInput = true;
         }
         StatsManager.count(this.m_featureName,"BoostUI","close");
         close();
      }
      
      private function get manager() : DreamWorldInnovationManager
      {
         return DreamWorldInnovationManager.getInstance(this.m_featureName);
      }
      
      override protected function release() : void
      {
         this.m_featureName = null;
         this.m_subFeatureName = null;
         super.release();
      }
   }
}

