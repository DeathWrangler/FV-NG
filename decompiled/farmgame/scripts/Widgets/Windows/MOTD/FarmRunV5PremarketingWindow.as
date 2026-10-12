package Widgets.Windows.MOTD
{
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FarmRunV5PremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "FarmRunV5PremarketingService";
      
      public static const SEEN_FLAG:String = "FarmRunV5PremarketingGrantFlag";
      
      private static const ITEM_QTY:int = 1;
      
      private var m_title_tf:ZwTextField;
      
      private var m_sizeMc:ZwWidget;
      
      private var m_choice1MC:ZwWidget;
      
      private var m_choice2MC:ZwWidget;
      
      private var m_checkmarkMC:ZwWidget;
      
      private var m_select1BT:FarmAnimatedTextButton;
      
      private var m_select2BT:FarmAnimatedTextButton;
      
      public function FarmRunV5PremarketingWindow(displayParams:Object = null)
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
               this.m_title_tf = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Farm Run")) as ZwTextField;
               this.m_title_tf.visible = true;
            }
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),false) as ZwWidget;
               m_animationMc.element.stop();
            }
            if(m_window.mainWindow["choice1_mc"])
            {
               this.m_choice1MC = addWidget(new ZwWidget(m_window.mainWindow.choice1_mc),true) as ZwWidget;
               if(m_window.mainWindow.choice1_mc["select_bt"])
               {
                  this.m_select1BT = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.choice1_mc["select_bt"],"Select",this.grantReward)) as FarmAnimatedTextButton;
               }
               this.m_choice1MC.element.visible = true;
            }
            if(m_window.mainWindow["choice2_mc"])
            {
               this.m_choice2MC = addWidget(new ZwWidget(m_window.mainWindow.choice2_mc),true) as ZwWidget;
               if(m_window.mainWindow.choice2_mc["select_bt"])
               {
                  this.m_select2BT = new FarmAnimatedTextButton(m_window.mainWindow.choice2_mc["select_bt"],"Select",this.grantReward);
               }
               if(m_window.mainWindow.choice2_mc["checkmark_mc"])
               {
                  this.m_checkmarkMC = addWidget(new ZwWidget(m_window.mainWindow.choice2_mc["checkmark_mc"]),false) as ZwWidget;
               }
               this.m_choice2MC.element.visible = true;
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Awesome!",onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.visible = false;
            }
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = addWidget(new ZwWidget(m_window.size_mc),true) as ZwWidget;
         }
      }
      
      private function onAnimation(event:Event) : void
      {
         if(m_animationMc)
         {
            if(m_animationMc.element.currentFrame == 60)
            {
               m_accept_bt.visible = true;
               m_animationMc.element.removeEventListener(Event.ENTER_FRAME,this.onAnimation,false);
            }
         }
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
            if(this.m_choice1MC)
            {
               this.m_choice1MC.element.visible = false;
            }
            if(this.m_choice2MC)
            {
               this.m_choice2MC.element.visible = false;
            }
            if(m_animationMc)
            {
               m_animationMc.element.visible = true;
               m_animationMc.element.gotoAndPlay(1);
               m_animationMc.element.addEventListener(Event.ENTER_FRAME,this.onAnimation,false);
            }
         }
         else
         {
            super.close();
         }
      }
      
      private function grantReward(event:MouseEvent) : void
      {
         if(this.m_checkmarkMC)
         {
            this.m_checkmarkMC.element.visible = true;
         }
         if(this.m_select1BT)
         {
            this.m_select1BT.enabled = false;
         }
         if(this.m_select2BT)
         {
            this.m_select2BT.enabled = false;
         }
         if(Global.player.getSeenFlag(SEEN_FLAG))
         {
            super.onClose(event);
         }
         else
         {
            Global.player.addGift("consume_organic_fertilizer","0",ITEM_QTY);
            Global.player.addGift("consume_unwither","0",ITEM_QTY);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward),true);
         }
      }
   }
}

