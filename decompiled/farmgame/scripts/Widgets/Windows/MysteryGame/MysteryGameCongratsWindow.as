package Widgets.Windows.MysteryGame
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   
   public class MysteryGameCongratsWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/FV_MysteryGame_Congrats.swf";
      
      private var m_itemAssetUrl:String;
      
      public function MysteryGameCongratsWindow(itemAssetUrl:String)
      {
         super(ASSET_URL,true,true);
         this.m_itemAssetUrl = itemAssetUrl;
      }
      
      override protected function postLoadComplete() : void
      {
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Congrats")));
         addWidget(new ZwTextField(m_window.desc1_tf,ZLocUtils.t("Dialogs","MysteryBoxGameSetCollectionBonus")));
         addWidget(new FarmIcon(m_window.icon_mc,this.m_itemAssetUrl));
         addWidget(new ZwTextField(m_window.desc2_tf,ZLocUtils.t("Dialogs","GiftboxFind")));
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","Okay"),onClose));
         StatsManager.count("fv_mysterygame","set_bonus_dialogue_impression");
      }
   }
}

