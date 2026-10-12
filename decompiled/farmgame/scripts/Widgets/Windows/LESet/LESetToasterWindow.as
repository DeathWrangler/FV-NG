package Widgets.Windows.LESet
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.LESetManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.ToasterWindow;
   import flash.events.Event;
   
   public class LESetToasterWindow extends ToasterWindow
   {
      
      protected static const POPUP_NAME:String = "LESetToaster";
      
      protected var DIALOG_ASSET:String = "assets/dialogs/FV_RP_Toaster.swf";
      
      private var m_frame:ZwFrame;
      
      private var m_titleMessage:String = ZLocUtils.t("Dialogs","LESetBonue_ToasterTitle");
      
      private var m_bodyMessage:String;
      
      public function LESetToasterWindow()
      {
         super(this.DIALOG_ASSET);
         this.name = POPUP_NAME;
         this.m_bodyMessage = ZLocUtils.t("Dialogs","LESetBonus_ToasterMessage",{"count":LESetManager.getCurrentCollectionSize() - LESetManager.getNumberOwned()});
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_frame = new ZwFrame(m_window);
         this.m_frame.addWidget(new ZwTextField(m_window.title_tf,this.m_titleMessage));
         this.m_frame.addWidget(new ZwTextField(m_window.subtitle_tf,this.m_bodyMessage));
         this.m_frame.addWidget(new FarmIcon(m_window.icon_mc,LESetManager.getCurrentCollectionRewardData().iconUrl));
         this.m_frame.addWidget(new FarmAnimatedTextButton(m_window.showme_bt,ZLocUtils.t("Dialogs","MoreInfo"),this.onMoreInfo));
      }
      
      private function onMoreInfo(evt:Event) : void
      {
         StatsManager.count("toaster","reward_purch_set","click");
         LESetManager.displayDialog();
      }
   }
}

