package Classes.util
{
   import Display.StrokeTextField;
   import Engine.Utilities;
   import Managers.DefconManager;
   import Managers.PerformanceExperimentManager;
   import flash.display.Sprite;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   
   public class PerformanceTracker extends Sprite
   {
      
      private static const UPDATE_INTERVAL:Number = 1000;
      
      private var m_lastUpdate:int;
      
      private var m_nextUpdate:int;
      
      private var m_frameCount:int;
      
      private var m_displayTextField:TextField;
      
      public function PerformanceTracker(textColor:Number = 16777215, fontSize:Number = 16)
      {
         super();
         var textFormat:TextFormat = new TextFormat(null,fontSize,textColor,true);
         this.m_displayTextField = new StrokeTextField(0,0.8);
         this.m_displayTextField.setTextFormat(textFormat);
         this.m_displayTextField.autoSize = TextFieldAutoSize.LEFT;
         this.m_displayTextField.defaultTextFormat = textFormat;
         this.m_displayTextField.selectable = false;
         Utilities.toggleInputOnlySelf(this.m_displayTextField,false);
         this.updateText(this.m_frameCount);
         addChild(this.m_displayTextField);
         this.m_lastUpdate = -1;
         this.m_nextUpdate = int.MAX_VALUE;
      }
      
      override public function set visible(value:Boolean) : void
      {
         super.visible = value;
         if(value && this.m_lastUpdate < 0)
         {
            this.m_frameCount = 0;
            this.updateText(this.m_frameCount);
            this.m_lastUpdate = GlobalEngine.currentTime;
            this.m_nextUpdate = this.m_lastUpdate + UPDATE_INTERVAL;
         }
         else if(this.m_lastUpdate >= 0)
         {
            this.m_lastUpdate = -1;
            this.m_nextUpdate = int.MAX_VALUE;
         }
      }
      
      public function update() : void
      {
         var currentTime:int = 0;
         var ellapsed:int = 0;
         if(visible)
         {
            ++this.m_frameCount;
            currentTime = getTimer();
            if(currentTime >= this.m_nextUpdate)
            {
               ellapsed = currentTime - this.m_lastUpdate;
               this.updateText(this.m_frameCount * UPDATE_INTERVAL / ellapsed);
               this.m_lastUpdate = currentTime;
               this.m_nextUpdate = currentTime + UPDATE_INTERVAL;
               this.m_frameCount = 0;
            }
         }
      }
      
      private function updateText(frameNum:Number) : void
      {
         var animTypes:Array = null;
         var text:String = "";
         text += Math.round(frameNum) + " fps\n";
         var mem:Number = Number(System.totalMemory / 1024 / 1024);
         text += mem.toFixed(2) + " MB\n";
         var totalObjects:int = Global.world.getNumObjects();
         var visibleObjects:int = Global.world.getNumVisibleObjects();
         var numAnimatingText:String = Global.world.numPlayingMapResources + "/";
         text += numAnimatingText + visibleObjects + "/" + totalObjects + " objects\n";
         var defconLockText:String = DefconManager.debugLock ? " (Locked)" : "";
         text += "DEFCON " + DefconManager.defconLevel.toString() + defconLockText + "\n";
         text += "Items Parsed " + Global.farmGameSettingsManager.numItemsXMLParsed;
         if(PerformanceExperimentManager.isInRasterMetadataExperiment)
         {
            animTypes = Global.world.getMapResourceContentTypes();
            text += "\n";
            text += "BM:" + animTypes[1] + " MC:" + animTypes[2] + " RMD:" + animTypes[3] + " AP:" + animTypes[4] + "\n";
            text += "Total: " + animTypes[0] + " Anim Objects\n";
         }
         this.m_displayTextField.text = text;
      }
   }
}

