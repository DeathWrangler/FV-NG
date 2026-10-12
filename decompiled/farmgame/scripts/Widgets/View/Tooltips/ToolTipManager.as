package Widgets.View.Tooltips
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class ToolTipManager
   {
      
      private static var _singleton_inst:ToolTipManager = null;
      
      private static const KEY_TEXT:String = "text";
      
      private static const KEY_VIEW:String = "view";
      
      private static const KEY_TEXTFIELD:String = "textfield";
      
      private var m_stage:Stage = null;
      
      private var m_mapping:Object = new Object();
      
      public function ToolTipManager(lock:StdUI_Manager_ToolTip_lock)
      {
         super();
         if(lock == null || _singleton_inst != null)
         {
            return;
         }
      }
      
      public static function getAndSetupInstance(pStage:Stage) : ToolTipManager
      {
         var tip:ToolTipManager = null;
         if(ToolTipManager._singleton_inst == null)
         {
            tip = getInstance();
            tip.m_stage = pStage;
            return tip;
         }
         return ToolTipManager._singleton_inst;
      }
      
      public static function getInstance() : ToolTipManager
      {
         if(ToolTipManager._singleton_inst == null)
         {
            ToolTipManager._singleton_inst = new ToolTipManager(new StdUI_Manager_ToolTip_lock());
         }
         return ToolTipManager._singleton_inst;
      }
      
      public function getMapping() : Object
      {
         return this.m_mapping;
      }
      
      public function addToolTip(pObject:Object, sToolTipText:String) : void
      {
         var data:Object = null;
         if(sToolTipText != null && sToolTipText != "")
         {
            pObject.addEventListener(MouseEvent.MOUSE_MOVE,this.onToolTipMouseMove,false,0,true);
            pObject.addEventListener(MouseEvent.ROLL_OVER,this.onToolTipRollOver,false,0,true);
            pObject.addEventListener(MouseEvent.ROLL_OUT,this.onToolTipRollOut,false,0,true);
            data = new Object();
            data[KEY_TEXT] = sToolTipText;
            this.m_mapping[pObject] = data;
         }
      }
      
      public function updateToolTip(pObject:Object, sToolTipText:String) : void
      {
         if(this.m_mapping[pObject])
         {
            this.m_mapping[pObject][KEY_TEXT] = sToolTipText;
         }
      }
      
      public function hasToolTip(pObject:Object) : Boolean
      {
         return Boolean(this.m_mapping[pObject]) && this.m_mapping[pObject][KEY_TEXT] != null && this.m_mapping[pObject][KEY_TEXT] != "";
      }
      
      public function removeToolTip(pObject:Object) : void
      {
         if(this.hasToolTip(pObject))
         {
            pObject.removeEventListener(MouseEvent.MOUSE_MOVE,this.onToolTipMouseMove);
            pObject.removeEventListener(MouseEvent.ROLL_OVER,this.onToolTipRollOver);
            pObject.removeEventListener(MouseEvent.ROLL_OUT,this.onToolTipRollOut);
            delete this.m_mapping[pObject];
         }
      }
      
      protected function onToolTipRollOver(event:MouseEvent) : void
      {
         var textFormat:TextFormat = null;
         var textField:TextField = null;
         var view:Sprite = null;
         var data:Object = this.m_mapping[event.currentTarget];
         if(Boolean(data && data[KEY_VIEW] == null) && Boolean(data[KEY_TEXT] != null) && data[KEY_TEXT] != "")
         {
            textFormat = new TextFormat("Merkin2",13,0,true);
            textField = new TextField();
            textField.multiline = true;
            textField.wordWrap = true;
            textField.width = 200;
            textField.autoSize = TextFieldAutoSize.LEFT;
            textField.defaultTextFormat = textFormat;
            textField.text = this.m_mapping[event.currentTarget][KEY_TEXT];
            textField.cacheAsBitmap = false;
            this.m_mapping[event.currentTarget][KEY_TEXTFIELD] = textField;
            view = new Sprite();
            this.m_mapping[event.currentTarget][KEY_VIEW] = view;
            this.drawBG(view,textField);
            this.updateToolTipPosition(event.currentTarget as DisplayObject);
            if(this.m_stage != null)
            {
               this.m_stage.addChild(view);
            }
         }
      }
      
      protected function drawBG(spr:Sprite, textfield:TextField) : void
      {
         var padding:Number = 8;
         spr.graphics.clear();
         while(spr.numChildren > 0)
         {
            spr.removeChildAt(0);
         }
         var bitmapData:BitmapData = new BitmapData(textfield.textWidth + padding * 2,textfield.textHeight + padding * 2,true,0);
         bitmapData.draw(textfield);
         var bitmap:Bitmap = new Bitmap(bitmapData);
         spr.addChild(bitmap);
         bitmap.x += padding - 2;
         bitmap.y += padding - 2;
         spr.graphics.beginFill(16777215);
         spr.graphics.lineStyle(1,5650027);
         spr.graphics.drawRoundRect(0,0,textfield.textWidth + padding * 2,textfield.textHeight + padding * 2,8,8);
         spr.graphics.endFill();
      }
      
      protected function onToolTipRollOut(event:MouseEvent) : void
      {
         if(Boolean(this.m_mapping[event.currentTarget]) && Boolean(this.m_mapping[event.currentTarget][KEY_VIEW]) && Boolean(this.m_stage))
         {
            this.m_stage.removeChild(this.m_mapping[event.currentTarget][KEY_VIEW]);
            delete this.m_mapping[event.currentTarget][KEY_VIEW];
            delete this.m_mapping[event.currentTarget][KEY_TEXTFIELD];
         }
      }
      
      protected function onToolTipMouseMove(event:MouseEvent) : void
      {
         this.updateToolTipPosition(event.currentTarget as DisplayObject);
      }
      
      protected function updateToolTipPosition(pObject:DisplayObject) : void
      {
         var pos:Point = null;
         if(Boolean(pObject) && Boolean(this.m_mapping[pObject]) && Boolean(this.m_mapping[pObject][KEY_VIEW]))
         {
            this.m_stage = pObject.stage;
            pos = new Point(this.m_stage.mouseX + 10,this.m_stage.mouseY + 10);
            if(this.m_stage.stageWidth - this.m_mapping[pObject][KEY_VIEW].width < pos.x)
            {
               pos.x = this.m_stage.mouseX - this.m_mapping[pObject][KEY_VIEW].width - 10;
            }
            if(this.m_stage.stageHeight - this.m_mapping[pObject][KEY_VIEW].height < pos.y)
            {
               pos.y = this.m_stage.mouseY - this.m_mapping[pObject][KEY_VIEW].height - 10;
            }
            this.m_mapping[pObject][KEY_VIEW].x = pos.x;
            this.m_mapping[pObject][KEY_VIEW].y = pos.y;
         }
      }
   }
}

class StdUI_Manager_ToolTip_lock
{
   
   public function StdUI_Manager_ToolTip_lock()
   {
      super();
   }
}
