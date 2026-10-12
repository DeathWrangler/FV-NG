package Widgets.Windows.MOTD
{
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class XHXInnovationPremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "HalloweenInnovationGhoulPremarketingService";
      
      public static const SEEN_FLAG:String = "HalloweenInnovationGhoulPremarketingGrantFlag";
      
      private static const ITEM_NAME:String = "horse_grotesqueviolet";
      
      private static const ITEM_QTY:int = 1;
      
      private var m_title_tf:ZwTextField;
      
      private var m_body_tf:ZwTextField;
      
      private var m_body2_tf:ZwTextField;
      
      private var m_sizeMc:ZwWidget;
      
      private var m_set:int = 0;
      
      private var cell1_mc:MovieClip;
      
      private var cell2_mc:MovieClip;
      
      private var cell3_mc:MovieClip;
      
      private var cell4_mc:MovieClip;
      
      private var m_selectBt:FarmAnimatedTextButton;
      
      public function XHXInnovationPremarketingWindow(displayParams:Object = null)
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
               this.m_title_tf = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Mean Machine")) as ZwTextField;
               this.m_title_tf.visible = true;
            }
            if(m_window.mainWindow["body_tf"])
            {
               this.m_body_tf = addWidget(new ZwTextField(m_window.mainWindow["body_tf"],"Click here and reveal a part for your invention!")) as ZwTextField;
               this.m_body_tf.visible = true;
            }
            if(m_window.mainWindow["body2_tf"])
            {
               this.m_body2_tf = addWidget(new ZwTextField(m_window.mainWindow["body2_tf"],"Invent more in Marbles’ Mean Machine coming this 22nd October, 2018.")) as ZwTextField;
               this.m_body2_tf.visible = false;
            }
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
               if(m_window.mainWindow.animation_mc["cell1_mc"])
               {
                  this.cell1_mc = m_window.mainWindow.animation_mc["cell1_mc"] as MovieClip;
                  this.cell1_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onGridClick);
               }
               if(m_window.mainWindow.animation_mc["cell2_mc"])
               {
                  this.cell2_mc = m_window.mainWindow.animation_mc["cell2_mc"] as MovieClip;
                  this.cell2_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onGridClick);
               }
               if(m_window.mainWindow.animation_mc["cell3_mc"])
               {
                  this.cell3_mc = m_window.mainWindow.animation_mc["cell3_mc"] as MovieClip;
                  this.cell3_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onGridClick);
               }
               if(m_window.mainWindow.animation_mc["cell4_mc"])
               {
                  this.cell4_mc = m_window.mainWindow.animation_mc["cell4_mc"] as MovieClip;
                  this.cell4_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onGridClick);
               }
               if(m_window.mainWindow.animation_mc["play_bt"])
               {
                  this.m_selectBt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc["play_bt"],"Play",this.onSelectBtClick)) as FarmAnimatedTextButton;
                  this.m_selectBt.visible = true;
               }
               m_animationMc.element.stop();
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Cool!",this.onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.visible = false;
            }
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = addWidget(new ZwWidget(m_window.size_mc),true) as ZwWidget;
         }
      }
      
      private function onGridClick(e:MouseEvent) : *
      {
         var currentFrame:int = (m_animationMc.element as MovieClip).currentFrame;
         if(Boolean(this.m_set) && Boolean(currentFrame > 0) && currentFrame < 6)
         {
            if(currentFrame == 2 && e.target.name == "cell1_mc")
            {
               (m_animationMc.element as MovieClip).gotoAndPlay(2);
            }
            else if(currentFrame == 3 && e.target.name == "cell2_mc")
            {
               (m_animationMc.element as MovieClip).gotoAndPlay(3);
            }
            else if(currentFrame == 4 && e.target.name == "cell3_mc")
            {
               (m_animationMc.element as MovieClip).gotoAndPlay(4);
            }
            else if(currentFrame == 5 && e.target.name == "cell4_mc")
            {
               (m_animationMc.element as MovieClip).gotoAndPlay(5);
               this.m_body_tf.text = "Jeepers! See what a magnificent beast you have created! This now belongs to you. Find it in your giftbox.";
               this.m_body_tf.visible = true;
               this.m_body2_tf.visible = true;
               m_accept_bt.visible = true;
            }
         }
      }
      
      private function onSelectBtClick(event:MouseEvent) : void
      {
         if(m_animationMc)
         {
            this.m_set = 1;
            m_animationMc.element.gotoAndPlay(1);
         }
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
      
      private function grantReward() : void
      {
         if(Global.player.getSeenFlag(SEEN_FLAG))
         {
            super.close();
         }
         else
         {
            Global.player.addGift(ITEM_NAME,"0",ITEM_QTY);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward));
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         this.grantReward();
         super.onAccept(event);
      }
   }
}

