package Widgets.Windows.MOTD
{
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class XISInnovationPremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "SeptemberInnovationPremarketingService";
      
      public static const SEEN_FLAG:String = "SeptemberInnovationPremarketingGrantFlag";
      
      private static const ITEM_NAME:String = "consume_organic_fertilizer";
      
      private static const ITEM_QTY:int = 1;
      
      private var m_title_tf:ZwTextField;
      
      private var m_sizeMc:ZwWidget;
      
      private var m_selectMc:ZwWidget;
      
      private var m_selectBt:FarmAnimatedTextButton;
      
      public function XISInnovationPremarketingWindow(displayParams:Object = null)
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
               this.m_title_tf = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"The Great Farm-Off")) as ZwTextField;
               this.m_title_tf.visible = true;
            }
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
               if(m_window.mainWindow.animation_mc["select_mc"])
               {
                  this.m_selectMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc["select_mc"]),false) as ZwWidget;
                  if(m_window.mainWindow.animation_mc.select_mc["select_bt"])
                  {
                     this.m_selectBt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.select_mc["select_bt"],"I’m going!",this.onSelectBtClick)) as FarmAnimatedTextButton;
                  }
                  this.m_selectMc.visible = true;
                  this.m_selectBt.visible = true;
               }
               m_animationMc.element.stop();
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Okay!",this.onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.visible = false;
            }
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = addWidget(new ZwWidget(m_window.size_mc),true) as ZwWidget;
         }
      }
      
      private function onSelectBtClick(event:MouseEvent) : void
      {
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         m_accept_bt.visible = true;
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

