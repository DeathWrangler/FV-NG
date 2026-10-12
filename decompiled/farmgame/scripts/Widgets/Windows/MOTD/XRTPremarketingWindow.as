package Widgets.Windows.MOTD
{
   import Classes.feed.GenericRewardFeed;
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class XRTPremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "XRTInnovationPremarketingService";
      
      public static const SEEN_FLAG:String = "XRTInnovationPremarketingGrantFlag";
      
      public static const THEMES_ARRAY:Array = ["Jazz Party","Gangster Party","Cinema Party","Sporty Party"];
      
      private static const ITEM1_NAME:String = "pkg_unwither_1";
      
      private static const ITEM1_INDEX:int = 0;
      
      private static const ITEM1_QTY:int = 2;
      
      private static const ITEM2_NAME:String = "pkg_instagrow_1pack";
      
      private static const ITEM2_INDEX:int = 1;
      
      private static const ITEM2_QTY:int = 2;
      
      private static const ITEM3_NAME:String = "consume_turbo_charger";
      
      private static const ITEM3_INDEX:int = 2;
      
      private static const ITEM3_QTY:int = 5;
      
      private static const ITEM4_NAME:String = "consume_organic_fertilizer";
      
      private static const ITEM4_INDEX:int = 3;
      
      private static const ITEM4_QTY:int = 2;
      
      private var m_itemName:String;
      
      private var m_bundleName:String;
      
      protected var m_title_tf:ZwTextField;
      
      protected var m_select0Mc:ZwWidget;
      
      protected var m_select1Mc:ZwWidget;
      
      protected var m_select2Mc:ZwWidget;
      
      protected var m_select3Mc:ZwWidget;
      
      private var m_closeBt:FarmButton;
      
      public function XRTPremarketingWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               this.m_title_tf = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Pick a party theme you like, to find something special just for you!")) as ZwTextField;
               this.m_title_tf.visible = true;
            }
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["select0_mc"])
            {
               this.m_select0Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select0_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["select1_mc"])
            {
               this.m_select1Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select1_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["select2_mc"])
            {
               this.m_select2Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select2_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc["select3_mc"])
            {
               this.m_select3Mc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select3_mc"]),false) as ZwWidget;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select0_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select0_bt"],"This Theme!",this.onStone0ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select1_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select1_bt"],"This Theme!",this.onStone1ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select2_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select2_bt"],"This Theme!",this.onStone2ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc.slots_mc["select3_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.slots_mc["select3_bt"],"This Theme!",this.onStone3ButtonClick)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow.animation_mc["close_bt"])
            {
               this.m_closeBt = addWidget(new FarmButton(m_window.mainWindow.animation_mc["close_bt"],onClose)) as FarmButton;
            }
            if(m_window.mainWindow["close_bt"])
            {
               this.m_closeBt = addWidget(new FarmButton(m_window.mainWindow["close_bt"],onClose)) as FarmButton;
            }
            if(m_animationMc)
            {
               m_animationMc.element.stop();
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Awesome!",onAccept)) as FarmAnimatedTextButton;
            }
            m_accept_bt.visible = false;
         }
      }
      
      protected function onStone0ButtonClick(event:MouseEvent) : void
      {
         this.m_select0Mc.visible = true;
         this.m_title_tf.text = "You sure love yourself a good " + THEMES_ARRAY[0] + ". Here is your gift!";
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.grantReward(ITEM1_NAME,ITEM1_QTY,ITEM1_INDEX);
      }
      
      protected function onStone1ButtonClick(event:MouseEvent) : void
      {
         this.m_select1Mc.visible = true;
         this.m_title_tf.text = "You sure love yourself a good " + THEMES_ARRAY[1] + ". Here is your gift!";
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.grantReward(ITEM2_NAME,ITEM2_QTY,ITEM2_INDEX);
      }
      
      protected function onStone2ButtonClick(event:MouseEvent) : void
      {
         this.m_select2Mc.visible = true;
         this.m_title_tf.text = "You sure love yourself a good " + THEMES_ARRAY[2] + ". Here is your gift!";
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.grantReward(ITEM3_NAME,ITEM3_QTY,ITEM3_INDEX);
      }
      
      protected function onStone3ButtonClick(event:MouseEvent) : void
      {
         this.m_select3Mc.visible = true;
         this.m_title_tf.text = "You sure love yourself a good " + THEMES_ARRAY[3] + ". Here is your gift!";
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         this.grantReward(ITEM4_NAME,ITEM4_QTY,ITEM4_INDEX);
      }
      
      protected function onShareClick(event:MouseEvent) : void
      {
         var _item:String = this.m_itemName;
         if(_item)
         {
            new GenericRewardFeed(_item,this.m_bundleName).shareFeed();
         }
         close();
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
      
      private function grantReward(itemName:String, quantity:int, itemIndex:int) : void
      {
         Global.player.addGift(itemName,"0",quantity);
         m_accept_bt.visible = true;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward,[itemIndex]));
      }
   }
}

