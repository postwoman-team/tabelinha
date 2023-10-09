require_relative '../lib/table'

describe Tabelinha do
  context :table do
    context 'when max_width is infinite' do
      context 'works for a single cell' do
        it 'with 0 padding' do
          options = {padding: 0, max_width: Float::INFINITY, space_linebroken: true}
          expect(Tabelinha.table([['cell']], options)).to eq(
            <<~TEXT
              ┌────┐
              │cell│
              └────┘
            TEXT
          )
        end

        it 'with 7 padding' do
          options = {padding: 7, max_width: Float::INFINITY, space_linebroken: true}
          expect(Tabelinha.table([['cell']], options)).to eq(
            <<~TEXT
              ┌──────────────────┐
              │       cell       │
              └──────────────────┘
            TEXT
          )
        end
      end

      context 'works for a 2x3 table' do
        it 'with custom characters' do
          options = {
            padding: 0,
            corners: {
              top_right: 'A',
              top_left: 'B',
              bottom_right: 'C',
              bottom_left: 'D'
            },
            straight: {
              vertical: 'l',
              horizontal: '-'
            },
            junctions: {
              top: 'T',
              middle: '+',
              bottom: 'W'
            }
          }

          expect(Tabelinha.table([['first', 'second'], ['third', 'i am fourth'], ['fifth', 'the sixth']], options)).to eq(
            <<~TEXT
             A-----T-----------B
             lfirstlsecond     l
             lthirdli am fourthl
             lfifthlthe sixth  l
             C-----W-----------D
            TEXT
          )
        end

        it 'with 0 padding' do
          options = {padding: 0, max_width: Float::INFINITY, space_linebroken: true}
          expect(Tabelinha.table([['first', 'second'], ['third', 'i am fourth'], ['fifth', 'the sixth']], options)).to eq(
            <<~TEXT
              ┌─────┬───────────┐
              │first│second     │
              │third│i am fourth│
              │fifth│the sixth  │
              └─────┴───────────┘
            TEXT
          )
        end

        it 'with 7 padding' do
          options = {padding: 7, max_width: Float::INFINITY, space_linebroken: true}
          expect(Tabelinha.table([['first', 'second'], ['third', 'i am fourth'], ['fifth', 'the sixth']], options)).to eq(
            <<~TEXT
              ┌───────────────────┬─────────────────────────┐
              │       first       │       second            │
              │       third       │       i am fourth       │
              │       fifth       │       the sixth         │
              └───────────────────┴─────────────────────────┘
            TEXT
          )
        end

        context 'with newlines' do
          it 'and space_linebroken is false' do
            options = {padding: 7, max_width: Float::INFINITY, space_linebroken: false}
            expect(Tabelinha.table([['first', "sec\nond"], ['third', 'i am fourth'], ['fifth', 'the sixth']], options)).to eq(
              <<~TEXT
                ┌───────────────────┬─────────────────────────┐
                │       first       │       sec               │
                │                   │       ond               │
                │       third       │       i am fourth       │
                │       fifth       │       the sixth         │
                └───────────────────┴─────────────────────────┘
              TEXT
            )
          end

          it 'and space_linebroken is true' do
            options = {padding: 7, max_width: Float::INFINITY, space_linebroken: true}
            expect(Tabelinha.table([['first', "sec\nond"], ['third', 'i am fourth'], ['fifth', 'the sixth']], options)).to eq(
              <<~TEXT
               ┌───────────────────┬─────────────────────────┐
               │       first       │       sec               │
               │                   │       ond               │
               │                   │                         │
               │       third       │       i am fourth       │
               │       fifth       │       the sixth         │
               └───────────────────┴─────────────────────────┘
              TEXT
            )
          end
        end
      end
    end

    context 'when max_width is 5(or any positive integer)' do
      it 'does not linebreak if unneeded' do
        options = {padding: 0, max_width: 5, space_linebroken: true}
        expect(Tabelinha.table([['a']], options)).to eq(
          <<~TEXT
            ┌─┐
            │a│
            └─┘
          TEXT
        )
      end

      context 'linebreaks a single cell' do
        it 'with 0 padding' do
          options = {padding: 0, max_width: 5, space_linebroken: true}
          expect(Tabelinha.table([['cell']], options)).to eq(
            <<~TEXT
              ┌───┐
              │cel│
              │l  │
              │   │
              └───┘
            TEXT
          )
        end

        it 'with 7 padding' do
          options = {padding: 7, max_width: 5, space_linebroken: true}
          expect(Tabelinha.table([['cell']], options)).to eq(
            <<~TEXT
              ┌─────────────────┐
              │       cel       │
              │       l         │
              │                 │
              └─────────────────┘
            TEXT
          )
        end

        it 'displays correctly even when space_linebroken is false' do
          options = {padding: 0, max_width: 5, space_linebroken: false}
          expect(Tabelinha.table([['cell']], options)).to eq(
            <<~TEXT
              ┌───┐
              │cel│
              │l  │
              └───┘
            TEXT
          )
        end
      end

      context 'linebreaks a 2x3 table' do
        it 'with 0 padding' do
          options = {padding: 0, max_width: 5, space_linebroken: true}
          expect(Tabelinha.table([['first', 'second'], ['third', 'i am fourth'], ['fifth', 'the sixth']], options)).to eq(
            <<~TEXT
              ┌─┬─┐
              │f│s│
              │i│e│
              │r│c│
              │s│o│
              │t│n│
              │ │d│
              │ │ │
              │t│i│
              │h│ │
              │i│a│
              │r│m│
              │d│ │
              │ │f│
              │ │o│
              │ │u│
              │ │r│
              │ │t│
              │ │h│
              │ │ │
              │f│t│
              │i│h│
              │f│e│
              │t│ │
              │h│s│
              │ │i│
              │ │x│
              │ │t│
              │ │h│
              │ │ │
              └─┴─┘
            TEXT
          )
        end

        it 'with 7 padding' do
          options = {padding: 7, max_width: 5, space_linebroken: true}
          expect(Tabelinha.table([['first', 'second'], ['third', 'i am fourth'], ['fifth', 'the sixth']], options)).to eq(
            <<~TEXT
              ┌───────────────┬───────────────┐
              │       f       │       s       │
              │       i       │       e       │
              │       r       │       c       │
              │       s       │       o       │
              │       t       │       n       │
              │               │       d       │
              │               │               │
              │       t       │       i       │
              │       h       │               │
              │       i       │       a       │
              │       r       │       m       │
              │       d       │               │
              │               │       f       │
              │               │       o       │
              │               │       u       │
              │               │       r       │
              │               │       t       │
              │               │       h       │
              │               │               │
              │       f       │       t       │
              │       i       │       h       │
              │       f       │       e       │
              │       t       │               │
              │       h       │       s       │
              │               │       i       │
              │               │       x       │
              │               │       t       │
              │               │       h       │
              │               │               │
              └───────────────┴───────────────┘
            TEXT
          )
        end
      end
    end

    context 'when max_width is 20 (or any positive integer)' do
      it 'linebreaks a 3x3 table deciding the best widths for each column' do
        options = {padding: 2, max_width: 20, space_linebroken: true}
        expect(Tabelinha.table(
            [
              ['short', 'im long ' * 5, 'smol'],
              ['sh', 'i am fourth', 'small'],
              ['sho!', 'short', 'just a bit']
            ],
            options
        )).to eq(
          <<~TEXT
            ┌─────────┬─────────┬─────────┐
            │  short  │  im lo  │  smol   │
            │         │  ng im  │         │
            │         │   long  │         │
            │         │   im l  │         │
            │         │  ong i  │         │
            │         │  m lon  │         │
            │         │  g im   │         │
            │         │  long   │         │
            │         │         │         │
            │  sh     │  i am   │  small  │
            │         │  fourt  │         │
            │         │  h      │         │
            │         │         │         │
            │  sho!   │  short  │  just   │
            │         │         │  a bit  │
            │         │         │         │
            └─────────┴─────────┴─────────┘
          TEXT
        )
      end

      it 'linebreaks a 3x3 table correctly even if there are escape characters' do
        options = {padding: 2, max_width: 31, space_linebroken: true}
        expect(Tabelinha.table(
            [
              ['short', 'im long ' * 5, 'smol'],
              ['sh', "i am fourth \e[38;2;249;38;114m and i have a bunch \e[m of \e[38;2;38;249;114mstyles\e[m 123", 'small'],
              ['sho!', 'short', 'just a bit']
            ],
            options
        )).to eq(
          <<~TEXT
          ┌─────────┬─────────────┬─────────────┐
          │  short  │  im long i  │  smol       │
          │         │  m long im  │             │
          │         │   long im   │             │
          │         │  long im l  │             │
          │         │  ong        │             │
          │         │             │             │
          │  sh     │  i am four  │  small      │
          │         │  th \e[38;2;249;38;114m and i\e[m  │             │
          │         │  \e[38;2;249;38;114m have a b\e[m  │             │
          │         │  \e[38;2;249;38;114munch \e[m of \e[m\e[m  │             │
          │         │  \e[38;2;249;38;114m\e[m\e[38;2;38;249;114mstyles\e[m 12\e[m\e[m\e[m\e[m  │             │
          │         │  \e[38;2;249;38;114m\e[m\e[38;2;38;249;114m\e[m3        \e[m\e[m\e[m\e[m  │             │
          │         │             │             │
          │  sho!   │  short      │  just a bi  │
          │         │             │  t          │
          │         │             │             │
          └─────────┴─────────────┴─────────────┘
          TEXT
        )
      end
    end
  end
end
