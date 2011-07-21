module Ray
  class Rect
    def collide?(rect)
      rect = rect.to_rect

      rect.x < x + width and
        x < rect.x + rect.width and
        rect.y < y + height and
        y < rect.y + rect.height
    end
  end
end