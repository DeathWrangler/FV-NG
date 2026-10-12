package Widgets.Windows.MOTD
{
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Charity.DonateWindow;
   import Widgets.Windows.Charity.DonateWindowFactory;
   import flash.events.Event;
   
   public class EdibleSchoolyardMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_Campaign_rainbowchard_join.swf";
      
      private static const ITEM_NAME:String = "rainbowchard";
      
      private var m_seed:SeedItem = Global.farmGameSettingsManager.getFarmItemByName(ITEM_NAME) as SeedItem;
      
      public function EdibleSchoolyardMOTDWindow()
      {
         if(this.m_seed)
         {
            super(ASSET_URL);
            return;
         }
         throw new Error("Invalid item: " + ITEM_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Campaign_" + ITEM_NAME + "_MOTD_Title")));
         addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","Campaign_" + ITEM_NAME + "_MOTD_Body")));
         addWidget(new ZwTextField(m_window.generic_1_tf,ZLocUtils.t("Dialogs","Campaign_" + ITEM_NAME + "_MOTD_item_info")));
         addWidget(new ZwTextField(m_window.generic_2_tf,ZLocUtils.tk_pk_asTitle(this.m_seed.friendlyName)));
         addWidget(new FarmIcon(m_window.icon_mc,this.m_seed.iconUrl));
         addWidget(new ZwTextField(m_window.generic_3_tf,ZLocUtils.t("Dialogs","Campaign_" + ITEM_NAME + "_MOTD_item_subinfo",{"item":ZLocUtils.t_pk(this.m_seed.friendlyName)})));
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","MoreInfo"),this.onDonateAccept));
      }
      
      private function onDonateAccept(event:Event) : void
      {
         if(this.m_seed)
         {
            FarmStatsManager.count("MOTD","click",m_currentMOTD.motdSeenFlag);
            UI.displayPopup(DonateWindowFactory.getInstance(this.m_seed,null,DonateWindow.SOURCE_MOTD));
         }
         else
         {
            ErrorManager.addError("Expectation failed, could not find item: " + ITEM_NAME);
         }
         onClose(event);
      }
   }
}

