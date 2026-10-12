package Display
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import flash.events.MouseEvent;
   
   public class DailyLottery extends Dialog
   {
      
      private var m_lotteryCash:int;
      
      private var m_accept:GenericButton;
      
      public function DailyLottery(lotteryCash:int, modal:Boolean = true)
      {
         m_dialogAsset = "assets/dialogs/FV_Lottery.swf";
         this.m_lotteryCash = lotteryCash;
         Global.player.gold -= this.m_lotteryCash;
         super(modal);
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.lottery_mc.congratulations_tf.text = ZLocUtils.t("Dialogs","Congratulations");
         m_window.lottery_mc.youwon_tf.text = ZLocUtils.t("Dialogs","YouWon",{"coinQuantity":this.m_lotteryCash});
         m_window.lottery_mc.youwon_tf.text = ZLocUtils.t("Dialogs","YouWon");
         m_window.lottery_mc.lotteryCash_tf.text = ZLocUtils.t("Dialogs","LotteryCash",{"coinQuantity":this.m_lotteryCash});
         m_window.lottery_mc.daily_tf.text = ZLocUtils.t("Dialogs","Daily");
         m_window.lottery_mc.comeback_tf.text = ZLocUtils.t("Dialogs","ComeBack");
         this.m_accept = new GenericButton(m_window.lottery_mc.ok_bt,this.onOkClick);
         this.m_accept.text = ZLocUtils.t("Dialogs","OkButton");
         StatsManager.milestone("lottery_md");
      }
      
      private function onOkClick(event:MouseEvent) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         Global.hud.unlockVisualEffects();
         Global.player.gold += this.m_lotteryCash;
         super.close();
      }
   }
}

