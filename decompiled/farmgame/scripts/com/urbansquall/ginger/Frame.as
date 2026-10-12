package com.urbansquall.ginger
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   
   internal class Frame
   {
      
      private var m_debugID:Number;
      
      public var numFrames:int;
      
      public var bitmapData:Array;
      
      public var width:Array;
      
      public var height:Array;
      
      public var offsetX:Array;
      
      public var offsetY:Array;
      
      public var frameID:String;
      
      public var preventDispose:Boolean = false;
      
      public function Frame(a_numFrames:int, a_bitmapData:BitmapData, a_numRotations:int, a_frameID:String, a_offsetX:Number = 0, a_offsetY:Number = 0)
      {
         super();
         this.m_debugID = Math.random();
         this.numFrames = a_numFrames;
         this.frameID = a_frameID;
         this.bitmapData = [];
         this.width = [];
         this.height = [];
         this.offsetX = [];
         this.offsetY = [];
         if(a_numRotations == 1)
         {
            this.createFrameWithNoRotation(a_bitmapData,a_offsetX,a_offsetY);
         }
         else
         {
            this.createRotatedFrame(a_bitmapData,a_numRotations,a_offsetX,a_offsetY);
         }
      }
      
      public function toString() : String
      {
         return "<Frame (" + this.m_debugID + ") bitmapData:" + this.bitmapData.length + " numFrames:" + this.numFrames + " frameID:" + this.frameID + " offsetX:" + this.offsetX + " offsetY:" + this.offsetY + ">";
      }
      
      public function dispose() : void
      {
         var bd:BitmapData = null;
         if(!this.preventDispose)
         {
            for each(bd in this.bitmapData)
            {
               bd.dispose();
            }
         }
      }
      
      public function changeID(a_id:String) : void
      {
         this.frameID = a_id;
      }
      
      private function createFrameWithNoRotation(a_bitmapData:BitmapData, a_offsetX:Number = 0, a_offsetY:Number = 0) : void
      {
         this.bitmapData.push(a_bitmapData);
         this.width.push(a_bitmapData.width);
         this.height.push(a_bitmapData.height);
         this.offsetX.push(-a_offsetX);
         this.offsetY.push(-a_offsetY);
      }
      
      private function createRotatedFrame(a_bitmapData:BitmapData, a_numRotations:int, a_offsetX:Number = 0, a_offsetY:Number = 0) : void
      {
         var largeSideX:int = Math.max(Math.abs(a_offsetX),a_offsetX + a_bitmapData.width);
         var largeSideY:int = Math.max(Math.abs(a_offsetY),a_offsetY + a_bitmapData.height);
         var tx:Number = largeSideX * Math.SQRT2;
         var ty:Number = largeSideY * Math.SQRT2;
         var maxTxy:Number = Math.max(tx,ty);
         var bdSize:Number = Math.ceil(Math.max(largeSideX * 2,largeSideY * 2) * Math.SQRT2);
         var mat:Matrix = new Matrix(1,0,0,1,maxTxy,maxTxy);
         var bd:BitmapData = new BitmapData(bdSize,bdSize,true,0);
         var container:Sprite = new Sprite();
         var bmpHolder:Sprite = new Sprite();
         var bmp:Bitmap = new Bitmap(a_bitmapData,PixelSnapping.ALWAYS,true);
         bmp.x = a_offsetX;
         bmp.y = a_offsetY;
         bmpHolder.addChild(bmp);
         container.addChild(bmpHolder);
         var ri:int = 0;
         while(ri < a_numRotations)
         {
            bd.fillRect(bd.rect,0);
            bd.draw(container,mat);
            this.bitmapData[ri] = bd.clone();
            this.width[ri] = bmpHolder.width;
            this.height[ri] = bmpHolder.height;
            this.offsetX[ri] = maxTxy;
            this.offsetY[ri] = maxTxy;
            bmpHolder.rotation += 360 / a_numRotations;
            ri++;
         }
      }
   }
}

