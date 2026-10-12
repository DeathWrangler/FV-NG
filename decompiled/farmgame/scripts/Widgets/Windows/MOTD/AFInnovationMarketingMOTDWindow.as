package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class AFInnovationMarketingMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "GrantRewardService";
      
      public static const SEEN_FLAG:String = "AFInnovationMarketingRewardGrantFlag";
      
      private var m_params:Object;
      
      private var m_slot0:FarmAnimatedButton;
      
      private var m_slot1:FarmAnimatedButton;
      
      private var m_slot2:FarmAnimatedButton;
      
      private var m_slot3:FarmAnimatedButton;
      
      public function AFInnovationMarketingMOTDWindow(displayParams:Object = null)
      {
         this.m_params = displayParams;
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window.mainWindow["title_tf"]) && m_currentMOTD.hasOwnProperty("title"))
         {
            m_window.mainWindow.title_tf.text = "Hands of Destiny";
         }
         if(m_window.mainWindow["body_tf"])
         {
            m_window.mainWindow.body_tf.text = "A glimpse into the future. What does the Hand of Destiny hold for you?";
         }
         if(m_window.mainWindow["body2_tf"])
         {
            m_window.mainWindow.body2_tf.text = "Pick a tile. Choose wisely!";
         }
         if(m_window.mainWindow["slots_mc"])
         {
            m_accept_bt.visible = false;
            m_window.mainWindow.slots_mc["reward_0_mc"].visible = false;
            m_window.mainWindow.slots_mc["reward_1_mc"].visible = false;
            m_window.mainWindow.slots_mc["reward_2_mc"].visible = false;
            m_window.mainWindow.slots_mc["reward_3_mc"].visible = false;
            if(m_window.mainWindow.slots_mc["slot_0_mc"])
            {
               addWidget(this.m_slot0 = new FarmAnimatedButton(m_window.mainWindow.slots_mc["slot_0_mc"],this.OnSlot0Click));
            }
            if(m_window.mainWindow.slots_mc["slot_1_mc"])
            {
               addWidget(this.m_slot1 = new FarmAnimatedButton(m_window.mainWindow.slots_mc["slot_1_mc"],this.OnSlot1Click));
            }
            if(m_window.mainWindow.slots_mc["slot_2_mc"])
            {
               addWidget(this.m_slot2 = new FarmAnimatedButton(m_window.mainWindow.slots_mc["slot_2_mc"],this.OnSlot2Click));
            }
            if(m_window.mainWindow.slots_mc["slot_3_mc"])
            {
               addWidget(this.m_slot3 = new FarmAnimatedButton(m_window.mainWindow.slots_mc["slot_3_mc"],this.OnSlot3Click));
            }
         }
      }
      
      private function grantReward(num:Number) : void
      {
         var itemName:String = null;
         var quantity:int = 0;
         switch(num)
         {
            case 1:
               itemName = "consume_turbo_charger";
               quantity = 3;
               break;
            case 2:
               itemName = "pkg_unwither_1";
               quantity = 1;
               break;
            case 3:
               itemName = "consume_organic_fertilizer";
               quantity = 1;
               break;
            case 4:
               itemName = "pkg_instagrow_1pack";
               quantity = 1;
         }
         Global.player.addGift(itemName,"0",quantity);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward,[num]));
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         m_window.mainWindow.title_tf.text = "CONGRATULATIONS!";
         m_window.mainWindow.body_tf.text = "Destiny has rewarded you with " + quantity + " " + item.friendlyTitle;
         m_window.mainWindow.body2_tf.text = "Find out what riches await you. Play the Hand of Destiny starting 17 July, 2017";
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
      
      private function OnSlot0Click(evt:MouseEvent) : void
      {
         this.disableAllSlots();
         var rand:Number = this.getRandomNumber(1,4);
         this.m_slot0.visible = false;
         m_window.mainWindow.slots_mc["reward_0_mc"].visible = true;
         (m_window.mainWindow.slots_mc["reward_0_mc"] as MovieClip).gotoAndStop(rand);
         m_accept_bt.visible = true;
         this.grantReward(rand);
      }
      
      private function OnSlot1Click(evt:MouseEvent) : void
      {
         this.disableAllSlots();
         var rand:Number = this.getRandomNumber(1,4);
         this.m_slot1.visible = false;
         m_window.mainWindow.slots_mc["reward_1_mc"].visible = true;
         (m_window.mainWindow.slots_mc["reward_1_mc"] as MovieClip).gotoAndStop(rand);
         m_accept_bt.visible = true;
         this.grantReward(rand);
      }
      
      private function OnSlot2Click(evt:MouseEvent) : void
      {
         this.disableAllSlots();
         var rand:Number = this.getRandomNumber(1,4);
         this.m_slot2.visible = false;
         m_window.mainWindow.slots_mc["reward_2_mc"].visible = true;
         (m_window.mainWindow.slots_mc["reward_2_mc"] as MovieClip).gotoAndStop(rand);
         m_accept_bt.visible = true;
         this.grantReward(rand);
      }
      
      private function OnSlot3Click(evt:MouseEvent) : void
      {
         this.disableAllSlots();
         var rand:Number = this.getRandomNumber(1,4);
         this.m_slot3.visible = false;
         m_window.mainWindow.slots_mc["reward_3_mc"].visible = true;
         (m_window.mainWindow.slots_mc["reward_3_mc"] as MovieClip).gotoAndStop(rand);
         m_accept_bt.visible = true;
         this.grantReward(rand);
      }
      
      private function disableAllSlots() : void
      {
         this.m_slot0.enabled = false;
         this.m_slot1.enabled = false;
         this.m_slot2.enabled = false;
         this.m_slot3.enabled = false;
      }
      
      private function getRandomNumber(minNum:Number, maxNum:Number) : Number
      {
         return Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum;
      }
   }
}

