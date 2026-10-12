package Widgets.Windows
{
   import Managers.TwentiesInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class TwentiesInnovationRewardWindow extends FarmWindow
   {
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BUILDING_TF:String = "title_tf";
      
      private const INFO_TF:String = "body_tf";
      
      private var m_featureName:String;
      
      private var m_highLighterMCArray:Array;
      
      private var m_progressLevelArray_mc:Array;
      
      private var m_progressLevelArray_tf:Array;
      
      public const ProgressLevelTextArray:Array = ["Abandoned Farm Shack","Shindig Shanty","Festive Hut","Celebration Cottage","Party Bungalow","Jamboree Mansion"];
      
      public const ProgressLevelPointArray:Array = ["1 week","2 weeks","3 weeks","4 weeks","5 weeks","6 weeks"];
      
      public const ProgressLevelSubtextArray:Array = ["Abandoned Farm Shack","Shindig Shanty","Festive Hut","Celebration Cottage","Party Bungalow","Jamboree Mansion"];
      
      private const BACK_BT:String = "okay_bt";
      
      private var m_knowMoreMC:MovieClip;
      
      private var m_IconMC:MovieClip;
      
      private var m_buildingTf:TextField;
      
      private var m_infoTf:TextField;
      
      private var m_knowMoreCloseBt:FarmButton;
      
      private var m_buildingGlowArray_mc:Array = [];
      
      private var m_previewMCArray:Array = [];
      
      private var m_rewardMCArray:Array = [];
      
      private var m_knowMoreBt:FarmAnimatedButton;
      
      private const FINALREWARD_WELCOME_SEEN_FLAG:String = "Twenties_Final_Reward_Welcome_flag";
      
      public function TwentiesInnovationRewardWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            addWidget(this.m_knowMoreBt = new FarmAnimatedButton(m_window.whatisthis_mc,this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty("knowMore_mc"))
         {
            this.m_knowMoreMC = m_window.knowMore_mc as MovieClip;
            this.m_knowMoreMC.visible = false;
            if(this.m_knowMoreMC.hasOwnProperty("close_bt"))
            {
               this.m_knowMoreCloseBt = new FarmButton(this.m_knowMoreMC["close_bt"],this.onKnowMoreMcClose);
               this.m_knowMoreBt.attachTooltip(new FarmTextTooltip("Know More"));
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "Build It To Win It!";
         }
         if(m_window.hasOwnProperty("npc_mc"))
         {
            m_window["npc_mc"].visible = true;
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            m_window[this.BODY_TF].text = "Keep upgrading the Farm Shack to harvest it everyday till June 2nd!";
         }
         if(m_window.hasOwnProperty("body2_tf"))
         {
            m_window["body2_tf"].visible = true;
            m_window["body2_tf"].text = "Keep upgrading the Farm Shack to harvest it everyday till June 2nd!";
         }
         if(m_window.hasOwnProperty("icon_mc"))
         {
            this.m_IconMC = m_window.icon_mc as MovieClip;
            this.m_IconMC.visible = true;
            this.m_IconMC.gotoAndPlay(2);
         }
         var currLevel:int = this.manager.getCurrentLevel() as int;
         if(m_window.hasOwnProperty(this.BUILDING_TF))
         {
            this.m_buildingTf = m_window.title_tf as TextField;
            this.m_buildingTf.visible = true;
         }
         if(m_window.hasOwnProperty(this.INFO_TF))
         {
            this.m_infoTf = m_window.body_tf as TextField;
            this.m_infoTf.visible = true;
         }
         if(m_window.hasOwnProperty(this.BACK_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.BACK_BT],"Awesome!",onClose));
         }
         if(!this.hasSeenFeatureWelcome())
         {
            Global.player.setSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
         }
         for(var j:int = 0; j < this.ProgressLevelTextArray.length; j++)
         {
            if(m_window.hasOwnProperty("info" + (j + 1).toString() + "_tf"))
            {
               m_window["info" + (j + 1).toString() + "_tf"].visible = true;
               m_window["info" + (j + 1).toString() + "_tf"].text = "Get an ‘Ecstatic’ Happiness Rating for at least " + this.ProgressLevelPointArray[j] + " to get this building!";
            }
         }
         this.m_highLighterMCArray = [];
         this.m_progressLevelArray_mc = [];
         this.m_progressLevelArray_tf = [];
         for(var i:int = 0; i < this.ProgressLevelTextArray.length; i++)
         {
            addWidget(this.m_progressLevelArray_mc[i] = new ZwFrame(m_window["icon" + i.toString() + "_mc"]),true);
            if(this.manager.getRewardLevel() - 1 != i)
            {
               this.m_progressLevelArray_mc[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(i));
               this.m_progressLevelArray_mc[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut(i));
            }
            if(Boolean(m_window["icon" + i.toString() + "_mc"]) && Boolean(m_window["icon" + i.toString() + "_mc"].hasOwnProperty("glow_mc")))
            {
               this.m_buildingGlowArray_mc[i] = m_window["icon" + i.toString() + "_mc"]["glow_mc"] as MovieClip;
            }
            if(m_window.hasOwnProperty("hitArea" + i.toString() + "_mc"))
            {
               addWidget(this.m_previewMCArray[i] = new ZwFrame(m_window["hitArea" + (i + 1).toString() + "_mc"]),true);
               if(this.manager.getRewardLevel() - 1 != i)
               {
                  this.m_previewMCArray[i].registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver(i));
                  this.m_previewMCArray[i].registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut(i));
               }
            }
            if(m_window.hasOwnProperty("consumable_" + i.toString() + "_ani"))
            {
               this.m_rewardMCArray[i] = m_window["consumable_" + i.toString() + "_ani"] as MovieClip;
               this.m_rewardMCArray[i].visible = false;
            }
         }
         if(this.m_previewMCArray[0])
         {
            this.m_previewMCArray[0].attachTooltip(new FarmTextTooltip("This building is not harvestable!"));
         }
         this.updateHighLighter();
      }
      
      public function onMouseOver(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            m_IconMC.visible = true;
            m_IconMC.gotoAndPlay(slotIndex + 1);
            if(m_buildingTf)
            {
               m_buildingTf.text = ProgressLevelTextArray[slotIndex];
            }
            if(m_infoTf)
            {
               m_infoTf.text = "Get a Legendary Rating for " + ProgressLevelPointArray[slotIndex] + " to get this building upgrade!";
            }
            if(m_buildingGlowArray_mc)
            {
               m_buildingGlowArray_mc[slotIndex].visible = true;
            }
         };
      }
      
      public function onMouseOut(slotIndex:int) : Function
      {
         return function(evt:MouseEvent):void
         {
            var activeRewardIndex:* = manager.getRewardLevel();
            if(slotIndex == activeRewardIndex)
            {
               updateHighLighter();
               return;
            }
            if(m_buildingTf)
            {
               m_buildingTf.text = "";
            }
            if(m_infoTf)
            {
               m_infoTf.text = "";
            }
            if(m_buildingGlowArray_mc)
            {
               m_buildingGlowArray_mc[slotIndex].visible = false;
            }
         };
      }
      
      private function updateHighLighter() : void
      {
         var activeRewardIndex:int = this.manager.getRewardLevel();
         if(activeRewardIndex >= 0)
         {
            if(this.m_buildingTf)
            {
               this.m_buildingTf.text = this.ProgressLevelTextArray[activeRewardIndex];
            }
            if(this.m_infoTf)
            {
               this.m_infoTf.text = "Get a Legendary Rating for " + this.ProgressLevelPointArray[activeRewardIndex] + " to get this building upgrade!";
            }
            if(this.m_buildingGlowArray_mc)
            {
               this.m_buildingGlowArray_mc[activeRewardIndex].visible = true;
            }
         }
      }
      
      private function get manager() : TwentiesInnovationManager
      {
         return TwentiesInnovationManager.getInstance();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.m_knowMoreMC.visible = true;
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
      }
      
      private function onKnowMoreMcClose(e:Event = null) : void
      {
         this.m_knowMoreMC.visible = false;
      }
      
      private function hasSeenFeatureWelcome() : Boolean
      {
         return Global.player.getSeenFlag(this.FINALREWARD_WELCOME_SEEN_FLAG);
      }
   }
}

