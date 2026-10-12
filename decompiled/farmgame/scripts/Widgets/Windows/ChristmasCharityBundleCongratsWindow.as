package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.QueuedIcon;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TXmasCharityCongratsSeen;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class ChristmasCharityBundleCongratsWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_CharityBundle2014_HL_Congrats.swf";
      
      private var m_itemName:String = "";
      
      public function ChristmasCharityBundleCongratsWindow(itemName:String)
      {
         super(ASSET_PATH);
         this.m_itemName = itemName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.title_tf))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Christmas_Charity_Congrats_Title")));
         }
         if(Boolean(m_window) && Boolean(m_window.subTitle_tf))
         {
            addWidget(new ZwTextField(m_window.subTitle_tf,ZLocUtils.t("Dialogs","Christmas_Charity_Congrats_SubTitle")));
         }
         if(Boolean(m_window) && Boolean(m_window.accept_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Awesome!",this.onClose));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         var xmsHudIcon:QueuedIcon = null;
         super.onClose(event);
         FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.CHRISTMAS_CHARITY_BUNDLES,this.m_itemName,1);
         if(Global.hud.rightSideIconQueue)
         {
            xmsHudIcon = Global.hud.rightSideIconQueue.getIconByFeatureName("christmasCharityBundles");
            if(xmsHudIcon)
            {
               Global.hud.rightSideIconQueue.removeIcon(xmsHudIcon);
            }
            Global.hud.refreshIconVisibility();
         }
         Global.worldManager.swapFarm("hlights",false);
         TransactionManager.addTransaction(new TXmasCharityCongratsSeen(this.m_itemName));
      }
   }
}

