package Widgets.Windows
{
   import Display.UI;
   import Managers.OrderBoard.CanadaInnovationManager;
   import Managers.PunchCardFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class PunchCardFeatureAvenuesWindow extends FarmWindow
   {
      
      private static const FEATURE_NAME:String = "PunchCard";
      
      private var m_featureName:String = null;
      
      private var m_header_tf:TextField;
      
      private var m_subheader_tf:TextField;
      
      private var m_avenues_mc:MovieClip;
      
      private var m_button1:FarmAnimatedTextButton;
      
      private var m_button2:FarmAnimatedTextButton;
      
      private var m_button3:FarmAnimatedTextButton;
      
      private var m_button4:FarmAnimatedTextButton;
      
      public function PunchCardFeatureAvenuesWindow(featureName:String = "PunchCard", assetUrl:String = null)
      {
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("spendavenue_tf"))
         {
            this.m_header_tf = TextField(m_window["spendavenue_tf"]);
            this.m_header_tf.text = "HOW TO GET TICKET PUNCHED?";
            this.m_header_tf.visible = true;
         }
         if(m_window.hasOwnProperty("subheadeer_tf"))
         {
            this.m_subheader_tf = TextField(m_window["subheadeer_tf"]);
            this.m_subheader_tf.text = "Any FC spent in above and any Maple Frontier features will contribute to your ticket’s punches!";
            this.m_subheader_tf.visible = true;
         }
         if(m_window.hasOwnProperty("spendavenue_mc"))
         {
            this.m_avenues_mc = m_window["spendavenue_mc"] as MovieClip;
            if(this.m_avenues_mc.hasOwnProperty("show0_bt"))
            {
               this.m_button1 = new FarmAnimatedTextButton(this.m_avenues_mc["show0_bt"],"Show",this.onTilesButttonClick);
               this.m_button1.visible = true;
            }
            if(this.m_avenues_mc.hasOwnProperty("show1_bt"))
            {
               this.m_button2 = new FarmAnimatedTextButton(this.m_avenues_mc["show1_bt"],"Let\'s Go",this.onInnovationButtonClick);
               this.m_button2.visible = true;
            }
            if(this.m_avenues_mc.hasOwnProperty("show2_bt"))
            {
               this.m_button3 = new FarmAnimatedTextButton(this.m_avenues_mc["show2_bt"],"Open",this.onMarketButtonClick);
               this.m_button3.visible = true;
            }
            if(this.m_avenues_mc.hasOwnProperty("show3_bt"))
            {
               this.m_button4 = new FarmAnimatedTextButton(this.m_avenues_mc["show3_bt"],"Show",this.onMarketButtonClick);
               this.m_button4.visible = true;
            }
            this.m_avenues_mc.visible = true;
         }
      }
      
      private function onMarketButtonClick(e:Event = null) : void
      {
         this.manager.closeMainWindow();
         UI.displayMarketDialog(FEATURE_NAME,null);
         this.close();
      }
      
      private function onTilesButttonClick(e:Event = null) : void
      {
         this.manager.closeMainWindow();
         var tilesArray:Array = CanadaInnovationManager.getInstance().lockedTilesArray;
         UI.displayMiniMarketDialog(tilesArray,null,"seed",null,true,false,false,true);
         this.close();
      }
      
      private function onInnovationButtonClick(e:Event = null) : void
      {
         this.manager.closeMainWindow();
         CanadaInnovationManager.getInstance().showMainUI();
         this.close();
      }
      
      private function get manager() : PunchCardFeatureManager
      {
         return PunchCardFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.enableInput = true;
            this.manager.m_mainWindow.untintWindow();
         }
         super.close();
      }
   }
}

