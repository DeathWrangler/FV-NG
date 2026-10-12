package Display
{
   import Classes.Achievement;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.InputManager;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Managers.ClickTrackingManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class Achievements extends SlotDialog
   {
      
      private static const NUM_SLOTS:int = 5;
      
      protected var m_disableInputImmediately:Boolean;
      
      public function Achievements(disableInputImmediately:Boolean = false)
      {
         this.m_disableInputImmediately = disableInputImmediately;
         if(this.m_disableInputImmediately)
         {
            InputManager.disableInput();
            Utilities.toggleInputAndChildren(Global.ui,false);
         }
         m_dialogAsset = "assets/dialogs/FV_Achievement.swf";
         super();
      }
      
      override protected function onHide() : void
      {
         if(this.m_disableInputImmediately)
         {
            InputManager.enableInput();
            this.m_disableInputImmediately = false;
         }
         super.onHide();
      }
      
      override protected function getNumSlots() : int
      {
         return NUM_SLOTS;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.achievements_tf.text = ZLocUtils.t("Dialogs","Ribbons");
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.arrowLt_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowRt_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
         m_tiles.push(m_window.achievementBlock1_mc,m_window.achievementBlock2_mc,m_window.achievementBlock3_mc,m_window.achievementBlock4_mc,m_window.achievementBlock5_mc);
         removeTiles();
         this.pushNewData();
         var compIdx:int = 0;
         while(compIdx < NUM_SLOTS && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
      }
      
      private function pushNewData() : void
      {
         var objectXML:XML = null;
         var achievement:Achievement = null;
         m_data = [];
         m_tileSet = 0;
         var objects:XMLList = Global.farmGameSettingsManager.getAchievements();
         for(var objectIdx:int = 0; objectIdx < objects.length(); objectIdx++)
         {
            objectXML = objects[objectIdx];
            if(this.checkExperiment(objectXML))
            {
               achievement = new Achievement(objectXML);
               if(!achievement.isDisabled)
               {
                  m_data.push(achievement);
               }
            }
         }
         fixArrows();
      }
      
      private function checkExperiment(objectXML:XML = null) : Boolean
      {
         var result:Boolean = true;
         var achExp:String = objectXML.@experiment;
         if(achExp != "" && 0 == Global.experimentManager.getExperimentVariant(achExp))
         {
            result = false;
         }
         return result;
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.arrowLt_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowRt_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
         event.stopPropagation();
         close();
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var mc:MovieClip = null;
         var code:String = null;
         var count:int = 0;
         var frame:int = 0;
         var tileSet:int = 0;
         var url:String = null;
         var icon:Loader = null;
         if(Boolean(m_tiles) && m_data[index + compId] != null)
         {
            mc = m_tiles[compId] as MovieClip;
            code = m_data[index + compId].code;
            mc.visible = true;
            mc.achievementTitle_tf.text = ZLocUtils.t_pk(m_data[index + compId].title);
            mc.achievementDescription_tf.text = m_data[index + compId].description;
            count = Global.player.achCounters[code] != null ? int(parseInt(Global.player.achCounters[code])) : 0;
            mc.numberCount_tf.text = Utilities.formatNumber(count);
            frame = 1;
            if(Global.player.achievements[code] != null)
            {
               frame = parseInt(Global.player.achievements[code]) + 2;
            }
            mc.gotoAndStop(frame);
            tileSet = m_tileSet;
            url = m_data[index + compId].getImageByName("icon_48");
            icon = LoadingManager.load(url,function(event:Event):void
            {
               var dispObj:* = undefined;
               if(Boolean(icon) && Boolean(icon.content) && m_tileSet == tileSet)
               {
                  Utilities.removeAllChildren(mc.icon);
                  dispObj = icon.content;
                  dispObj.width = 55;
                  dispObj.height = 55;
                  mc.icon.addChild(dispObj);
               }
            });
         }
      }
   }
}

