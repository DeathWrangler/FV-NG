package Widgets.Windows
{
   import Managers.JumbleVillaManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class JumbleVillaFinderUpgradeWindow extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "JumbleVilla";
      
      private static const NO_OF_LEVELS:int = 4;
      
      private var m_buy_bt:FarmAnimatedTextButton;
      
      private var m_levels_mc:Array = [];
      
      private var m_highs_mc:Array = [];
      
      private var m_size_mc:MovieClip;
      
      private var m_texts_tf:Array = [];
      
      private var m_title_tf:ZwTextField;
      
      private var m_subtitle_tf:ZwTextField;
      
      public function JumbleVillaFinderUpgradeWindow(featureName:String = "JumbleVilla", assetUrl:String = null)
      {
         super(featureName,assetUrl);
      }
      
      private static function get manager() : JumbleVillaManager
      {
         return JumbleVillaManager.getInstance(FEATURE_NAME);
      }
      
      override protected function postLoadComplete() : void
      {
         var i:int = 0;
         var m_level_mc:MovieClip = null;
         var m_high_mc:MovieClip = null;
         var m_text_tf:ZwTextField = null;
         var visiblity:Boolean = false;
         var finderText:String = null;
         var tilesRequiredForFinderLevel:Number = NaN;
         if(m_window)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(this.m_title_tf = new ZwTextField(m_window["title_tf"],"JUMBLEVILLE!"));
               this.m_title_tf.visible = true;
            }
            if(m_window.hasOwnProperty("subtitle_tf"))
            {
               addWidget(this.m_subtitle_tf = new ZwTextField(m_window["subtitle_tf"],"Get more land to upgrade your finder!"));
            }
            if(m_window.hasOwnProperty("size_mc"))
            {
               this.m_size_mc = m_window["size_mc"] as MovieClip;
               this.m_size_mc.visible = true;
            }
            if(m_window.hasOwnProperty("buy_bt"))
            {
               addWidget(this.m_buy_bt = new FarmAnimatedTextButton(m_window["buy_bt"],"Upgrade!",this.onClickBuyButton));
               this.m_buy_bt.visible = manager.getCurrentFinderLevel() < 3;
            }
            for(i = 0; i < NO_OF_LEVELS; i++)
            {
               if(m_window.hasOwnProperty("levels" + String(i) + "_mc"))
               {
                  m_level_mc = m_window["levels" + String(i) + "_mc"] as MovieClip;
                  if(m_level_mc.hasOwnProperty("high_mc"))
                  {
                     m_high_mc = m_level_mc["high_mc"] as MovieClip;
                  }
                  if(m_level_mc.hasOwnProperty("text" + String(i + 1) + "_tf"))
                  {
                     m_text_tf = new ZwTextField(m_level_mc["text" + String(i + 1) + "_tf"]);
                  }
               }
               this.m_levels_mc.push(m_level_mc);
               if(this.m_levels_mc[i])
               {
                  this.m_levels_mc[i].visible = true;
               }
               this.m_texts_tf.push(m_text_tf);
               if(this.m_texts_tf[i])
               {
                  tilesRequiredForFinderLevel = manager.getTilesRequiredForFinderLevel(i);
                  if(tilesRequiredForFinderLevel > 0)
                  {
                     finderText = "Get " + String(tilesRequiredForFinderLevel) + " more land expansions to get this finder!";
                  }
                  else if(i == manager.getCurrentFinderLevel())
                  {
                     finderText = "You currently have this finder!";
                  }
                  else
                  {
                     finderText = "You already have a better finder!";
                  }
                  this.m_texts_tf[i].text = finderText;
                  this.m_texts_tf[i].visible = true;
               }
               this.m_highs_mc.push(m_high_mc);
               visiblity = i == manager.getCurrentFinderLevel();
               if(this.m_highs_mc[i])
               {
                  this.m_highs_mc[i].visible = visiblity;
               }
            }
         }
         if(manager.mainWindow)
         {
            manager.mainWindow.hideFinderAndBonusRewards();
            manager.mainWindow.tintWindow();
            manager.mainWindow.enableInput = false;
         }
      }
      
      private function onClickBuyButton(event:MouseEvent) : void
      {
         this.close();
         manager.highlightTiles();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(manager.mainWindow)
         {
            manager.mainWindow.unhideFinderAndBonusRewards();
            manager.mainWindow.untintWindow();
            manager.mainWindow.enableInput = true;
         }
         super.onClose(event);
      }
   }
}

